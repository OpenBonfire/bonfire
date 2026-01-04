import 'package:bonfire/features/authentication/repositories/auth.dart';
import 'package:bonfire/shared/pagination/pagination_controller.dart';
import 'package:firebridge/firebridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages.g.dart';

@Riverpod()
class ChannelMessages extends _$ChannelMessages {
  late final PaginationHelper<Message> _paginationHelper;
  final int _limit = 20;

  @override
  Future<List<Message>> build(Snowflake channelId) async {
    _paginationHelper = PaginationHelper<Message>(
      pageSize: _limit,
      getState: () => state,
      setState: (newState) => state = newState.whenData((data) => data ?? []),
      fetchPage: (page, limit, cursor) async {
        final client = ref.read(clientControllerProvider);
        return await client!
            .messages(channelId: channelId)
            .fetchMany(after: cursor?.id);
      },
      getId: (conversation) => conversation.id,
      debugName: 'ChannelMessages($channelId)',
    );

    final result = await _paginationHelper.initialize();
    return result ?? [];
  }

  Future<void> loadMore() => _paginationHelper.loadMore();
}
