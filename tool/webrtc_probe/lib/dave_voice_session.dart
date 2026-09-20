import 'dart:async';

import 'package:dave/dave.dart';
import 'package:firebridge/firebridge.dart';
import 'package:flutter/foundation.dart';

import 'voice_gateway.dart';

/// A key ratchet becoming available (or changing, after an MLS group
/// change) for [userId]. The media layer should feed this into that
/// participant's [DaveDecryptor] (or, when [isSelf], the local
/// [DaveEncryptor]).
///
/// The [ratchet] is owned by [DaveVoiceSession] - callers must not
/// [DaveKeyRatchet.dispose] it themselves.
class DaveRatchetUpdate {
  const DaveRatchetUpdate({required this.userId, required this.ratchet, required this.isSelf});
  final Snowflake userId;
  final DaveKeyRatchet ratchet;
  final bool isSelf;
}

/// Drives a [DaveSession] (the `dave` package's libdave bindings) from a
/// [VoiceGateway]'s DAVE protocol opcode streams (21-31), implementing the
/// handshake described at
/// https://docs.discord.food/topics/voice-connections#end-to-end-encryption
/// and https://daveprotocol.com/ (see "Protocol Transitions", "MLS Group
/// Changes", "Proposals and Commits", "Recovery from Invalid Commit or
/// Welcome").
///
/// Emits [onRatchetUpdate] whenever a participant's (or our own) key
/// ratchet becomes available or changes - the media layer wires those into
/// its per-participant `DaveEncryptor`/`DaveDecryptor`s.
///
/// Does not yet implement every edge case in the protocol (notably "sole
/// member reset" and full downgrade-to-passthrough sequencing) - see the
/// TODOs below. The core join/establish-group/rotate-on-membership-change
/// path is complete.
class DaveVoiceSession {
  DaveVoiceSession({
    required VoiceGateway gateway,
    required Snowflake selfUserId,
    required Snowflake groupId,
  }) : _gateway = gateway,
       _selfUserId = selfUserId,
       _groupId = groupId {
    _subscriptions = [
      gateway.onDavePrepareEpoch.listen(_handlePrepareEpoch),
      gateway.onDaveExternalSenderPackage.listen(_handleExternalSenderPackage),
      gateway.onDaveProposals.listen(_handleProposals),
      gateway.onDaveAnnounceCommitTransition.listen(_handleAnnounceCommitTransition),
      gateway.onDaveWelcome.listen(_handleWelcome),
      gateway.onDaveExecuteTransition.listen(_handleExecuteTransition),
      gateway.onDavePrepareTransition.listen(_handlePrepareTransition),
      gateway.onClientsConnect.listen((event) => _recognizedUserIds.addAll(event.userIds)),
      gateway.onClientDisconnect.listen((event) => _recognizedUserIds.remove(event.userId)),
    ];
  }

  final VoiceGateway _gateway;
  final Snowflake _selfUserId;
  final Snowflake _groupId;
  late final List<StreamSubscription<void>> _subscriptions;

  DaveSession? _session;
  // Default to our own max supported version rather than 0 (= no DAVE) so
  // that a lazily-created session (see _ensureSession) is actually usable
  // even if Prepare Epoch never arrives to give us an authoritative value.
  int _protocolVersion = daveMaxSupportedProtocolVersion();
  final Set<String> _recognizedUserIds = {};
  final Map<Snowflake, DaveKeyRatchet> _ratchets = {};

  /// Ratchets derived after processing a commit/welcome, held until the
  /// matching Execute Transition confirms it's time to actually switch to
  /// them - see "Protocol Transitions" in the whitepaper: senders must keep
  /// using the old context until execution is confirmed.
  final Map<int, List<DaveRatchetUpdate>> _pendingRatchetsByTransition = {};

  final _ratchetUpdateController = StreamController<DaveRatchetUpdate>.broadcast();

  /// Fires when a participant's (or our own, [DaveRatchetUpdate.isSelf])
  /// key ratchet becomes available or changes.
  ///
  /// This is a plain broadcast stream with no replay - a listener only
  /// sees updates that happen *after* it subscribes. The MLS handshake
  /// this class drives only depends on the gateway connection, so it can
  /// (and in practice does) finish well before a late subscriber - e.g.
  /// `VoiceMediaSession.start()`, which waits on IP discovery/mic
  /// permission/SoLoud init first - attaches. Late subscribers must catch
  /// up via [knownRatchets] themselves; see its doc.
  Stream<DaveRatchetUpdate> get onRatchetUpdate => _ratchetUpdateController.stream;

  /// Snapshot of every ratchet derived so far, keyed by user id (including
  /// our own, under [_selfUserId]). For a subscriber attaching to
  /// [onRatchetUpdate] after some ratchets have already been derived -
  /// see that getter's doc - read this first and handle each entry as if
  /// it were an [onRatchetUpdate] event, *before* relying on the live
  /// stream for anything further.
  Map<Snowflake, DaveKeyRatchet> get knownRatchets => Map.unmodifiable(_ratchets);

  void _handlePrepareEpoch(DavePrepareEpoch event) {
    debugPrint('[VoiceDave] prepare epoch ${event.epoch} (protocol v${event.protocolVersion})');
    _protocolVersion = event.protocolVersion;

    if (event.epoch == 1) {
      // A brand new MLS group is being created for this call.
      _resetLocalSession();
      _sendFreshKeyPackage();
    } else {
      _session?.protocolVersion = event.protocolVersion;
    }
  }

  Uint8List? _externalSender;

  /// In practice the Gateway doesn't always send Prepare Epoch (opcode 24)
  /// before other DAVE traffic - observed live, joining a channel someone
  /// else is already in can deliver External Sender Package/Proposals with
  /// no preceding Prepare Epoch at all. Don't hard-depend on opcode 24 as
  /// the only trigger for creating our local session: lazily create it (with
  /// our own best-guess protocol version) the first time any DAVE handler
  /// needs one, so we're never stuck silently ignoring messages because
  /// `_session` is null.
  void _ensureSession() {
    if (_session != null) return;
    debugPrint(
      '[VoiceDave] lazily initializing local session (protocol v$_protocolVersion) - '
      'no Prepare Epoch seen yet for this connection',
    );
    _resetLocalSession();
    _sendFreshKeyPackage();
  }

  void _handleExternalSenderPackage(DaveExternalSenderPackage event) {
    debugPrint('[VoiceDave] external sender package received (${event.data.length}B)');
    _externalSender = event.data;
    _ensureSession();
    _session?.setExternalSender(event.data);
  }

  void _handleProposals(DaveProposals event) {
    debugPrint(
      '[VoiceDave] proposals received (${event.data.length}B, recognizedUserIds=$_recognizedUserIds)',
    );
    _ensureSession();
    final session = _session;
    if (session == null) {
      debugPrint('[VoiceDave] received proposals with no active session; ignoring');
      return;
    }
    try {
      final commitWelcome = session.processProposals(event.data, _recognizedUserIds.toList());
      debugPrint('[VoiceDave] processed proposals -> commitWelcome ${commitWelcome.length}B, sending');
      _gateway.sendDaveCommitWelcome(commitWelcome);
    } catch (error, stackTrace) {
      debugPrint('[VoiceDave] failed to process proposals: $error\n$stackTrace');
    }
  }

  void _handleAnnounceCommitTransition(DaveAnnounceCommitTransition event) {
    _ensureSession();
    final session = _session;
    if (session == null) {
      debugPrint('[VoiceDave] received commit with no active session; ignoring');
      return;
    }
    try {
      final result = session.processCommit(event.commitData);
      final failed = result.isFailed;
      final ignored = result.isIgnored;
      final rosterIds = failed ? const <int>[] : result.rosterMemberIds;
      result.dispose();
      debugPrint(
        '[VoiceDave] processCommit(transition=${event.transitionId}) -> '
        'failed=$failed ignored=$ignored roster=$rosterIds',
      );

      if (failed) {
        debugPrint('[VoiceDave] commit for transition ${event.transitionId} failed; recovering');
        _gateway.sendDaveInvalidCommitWelcome(event.transitionId);
        _resetLocalSession();
        _sendFreshKeyPackage();
        return;
      }
      if (ignored) {
        debugPrint('[VoiceDave] commit for transition ${event.transitionId} ignored (stale epoch)');
        return;
      }

      _deriveAndDispatchRatchets(rosterIds, event.transitionId);
      _gateway.sendDaveTransitionReady(event.transitionId);
    } catch (error, stackTrace) {
      debugPrint('[VoiceDave] error processing commit: $error\n$stackTrace');
      _gateway.sendDaveInvalidCommitWelcome(event.transitionId);
      _resetLocalSession();
      _sendFreshKeyPackage();
    }
  }

  void _handleWelcome(DaveWelcome event) {
    _ensureSession();
    final session = _session;
    if (session == null) {
      debugPrint('[VoiceDave] received welcome with no active session; ignoring');
      return;
    }
    try {
      final result = session.processWelcome(event.welcomeData, _recognizedUserIds.toList());
      final rosterIds = result.rosterMemberIds;
      result.dispose();
      debugPrint(
        '[VoiceDave] processWelcome(transition=${event.transitionId}) -> roster=$rosterIds',
      );

      _deriveAndDispatchRatchets(rosterIds, event.transitionId);
      _gateway.sendDaveTransitionReady(event.transitionId);
    } catch (error, stackTrace) {
      debugPrint('[VoiceDave] error processing welcome: $error\n$stackTrace');
      _gateway.sendDaveInvalidCommitWelcome(event.transitionId);
      _resetLocalSession();
      _sendFreshKeyPackage();
    }
  }

  /// Derives ratchets for [rosterUserIds] and either applies them right
  /// away or defers them until [_handleExecuteTransition] confirms it,
  /// depending on [transitionId] - per the whitepaper's "Protocol
  /// Transitions": transition ID 0 means "not a real protocol transition,
  /// execute immediately" and the Gateway will *not* follow up with an
  /// Execute Transition (opcode 30) for it. Observed live: the initial
  /// group-formation commit always uses transition ID 0, so treating every
  /// transition as "wait for opcode 30" (the previous behavior) meant
  /// ratchets were derived but never actually applied for a call's first
  /// commit - every decrypt kept failing with MISSING_KEY_RATCHET forever.
  void _deriveAndDispatchRatchets(List<int> rosterUserIds, int transitionId) {
    final updates = _deriveRatchets(rosterUserIds);
    debugPrint(
      '[VoiceDave] derived ${updates.length} ratchet(s) for transition $transitionId: '
      '${updates.map((u) => '${u.userId}${u.isSelf ? '(self)' : ''}').join(', ')}',
    );
    if (transitionId == 0) {
      _applyRatchets(updates);
    } else {
      _pendingRatchetsByTransition[transitionId] = updates;
    }
  }

  void _applyRatchets(List<DaveRatchetUpdate> updates) {
    for (final update in updates) {
      _ratchets[update.userId]?.dispose();
      _ratchets[update.userId] = update.ratchet;
      _ratchetUpdateController.add(update);
    }
  }

  void _handleExecuteTransition(DaveExecuteTransition event) {
    final ratchets = _pendingRatchetsByTransition.remove(event.transitionId);
    debugPrint(
      '[VoiceDave] executing transition ${event.transitionId} '
      '(${ratchets?.length ?? 0} pending ratchet update(s))',
    );
    if (ratchets == null) return;
    _applyRatchets(ratchets);
  }

  void _handlePrepareTransition(DavePrepareTransition event) {
    debugPrint(
      '[VoiceDave] prepare transition ${event.transitionId} '
      '(protocol v${event.protocolVersion})',
    );
    // TODO: full downgrade-to-passthrough handling (protocol_version == 0).
    // transitionId == 0 means it can execute immediately per the
    // whitepaper; otherwise we just acknowledge readiness right away since
    // there's no additional local state to prepare beyond what processing
    // the associated commit/welcome already covers.
    _gateway.sendDaveTransitionReady(event.transitionId);
  }

  /// Derives fresh key ratchets for every member in [rosterUserIds] (as
  /// `uint64` snowflakes from a commit/welcome result), including our own.
  List<DaveRatchetUpdate> _deriveRatchets(List<int> rosterUserIds) {
    final session = _session;
    if (session == null) return const [];

    final updates = <DaveRatchetUpdate>[];
    for (final rawId in rosterUserIds) {
      final userId = Snowflake(rawId);
      try {
        final ratchet = session.getKeyRatchet(userId.toString());
        updates.add(DaveRatchetUpdate(userId: userId, ratchet: ratchet, isSelf: userId == _selfUserId));
      } catch (error, stackTrace) {
        debugPrint('[VoiceDave] failed to derive key ratchet for $userId: $error\n$stackTrace');
      }
    }
    return updates;
  }

  void _resetLocalSession() {
    _session?.dispose();
    _session = DaveSession(
      onMlsFailure: (source, reason) => debugPrint('[VoiceDave] MLS failure in $source: $reason'),
    );
    _session!.init(version: _protocolVersion, groupId: _groupId.value, selfUserId: _selfUserId.toString());
    if (_externalSender != null) {
      _session!.setExternalSender(_externalSender!);
    }
  }

  void _sendFreshKeyPackage() {
    final session = _session;
    if (session == null) return;
    _gateway.sendDaveKeyPackage(session.marshalledKeyPackage);
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    for (final ratchet in _ratchets.values) {
      ratchet.dispose();
    }
    _ratchets.clear();
    _session?.dispose();
    _session = null;
    await _ratchetUpdateController.close();
  }
}
