// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'types.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DataChannelEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataChannelEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DataChannelEvent()';
}


}

/// @nodoc
class $DataChannelEventCopyWith<$Res>  {
$DataChannelEventCopyWith(DataChannelEvent _, $Res Function(DataChannelEvent) __);
}


/// Adds pattern-matching-related methods to [DataChannelEvent].
extension DataChannelEventPatterns on DataChannelEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DataChannelEvent_Open value)?  open,TResult Function( DataChannelEvent_Message value)?  message,TResult Function( DataChannelEvent_Closing value)?  closing,TResult Function( DataChannelEvent_Closed value)?  closed,TResult Function( DataChannelEvent_Error value)?  error,TResult Function( DataChannelEvent_BufferedAmountLow value)?  bufferedAmountLow,TResult Function( DataChannelEvent_BufferedAmountHigh value)?  bufferedAmountHigh,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DataChannelEvent_Open() when open != null:
return open(_that);case DataChannelEvent_Message() when message != null:
return message(_that);case DataChannelEvent_Closing() when closing != null:
return closing(_that);case DataChannelEvent_Closed() when closed != null:
return closed(_that);case DataChannelEvent_Error() when error != null:
return error(_that);case DataChannelEvent_BufferedAmountLow() when bufferedAmountLow != null:
return bufferedAmountLow(_that);case DataChannelEvent_BufferedAmountHigh() when bufferedAmountHigh != null:
return bufferedAmountHigh(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DataChannelEvent_Open value)  open,required TResult Function( DataChannelEvent_Message value)  message,required TResult Function( DataChannelEvent_Closing value)  closing,required TResult Function( DataChannelEvent_Closed value)  closed,required TResult Function( DataChannelEvent_Error value)  error,required TResult Function( DataChannelEvent_BufferedAmountLow value)  bufferedAmountLow,required TResult Function( DataChannelEvent_BufferedAmountHigh value)  bufferedAmountHigh,}){
final _that = this;
switch (_that) {
case DataChannelEvent_Open():
return open(_that);case DataChannelEvent_Message():
return message(_that);case DataChannelEvent_Closing():
return closing(_that);case DataChannelEvent_Closed():
return closed(_that);case DataChannelEvent_Error():
return error(_that);case DataChannelEvent_BufferedAmountLow():
return bufferedAmountLow(_that);case DataChannelEvent_BufferedAmountHigh():
return bufferedAmountHigh(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DataChannelEvent_Open value)?  open,TResult? Function( DataChannelEvent_Message value)?  message,TResult? Function( DataChannelEvent_Closing value)?  closing,TResult? Function( DataChannelEvent_Closed value)?  closed,TResult? Function( DataChannelEvent_Error value)?  error,TResult? Function( DataChannelEvent_BufferedAmountLow value)?  bufferedAmountLow,TResult? Function( DataChannelEvent_BufferedAmountHigh value)?  bufferedAmountHigh,}){
final _that = this;
switch (_that) {
case DataChannelEvent_Open() when open != null:
return open(_that);case DataChannelEvent_Message() when message != null:
return message(_that);case DataChannelEvent_Closing() when closing != null:
return closing(_that);case DataChannelEvent_Closed() when closed != null:
return closed(_that);case DataChannelEvent_Error() when error != null:
return error(_that);case DataChannelEvent_BufferedAmountLow() when bufferedAmountLow != null:
return bufferedAmountLow(_that);case DataChannelEvent_BufferedAmountHigh() when bufferedAmountHigh != null:
return bufferedAmountHigh(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  open,TResult Function( Uint8List data,  bool isText)?  message,TResult Function()?  closing,TResult Function()?  closed,TResult Function()?  error,TResult Function()?  bufferedAmountLow,TResult Function()?  bufferedAmountHigh,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DataChannelEvent_Open() when open != null:
return open();case DataChannelEvent_Message() when message != null:
return message(_that.data,_that.isText);case DataChannelEvent_Closing() when closing != null:
return closing();case DataChannelEvent_Closed() when closed != null:
return closed();case DataChannelEvent_Error() when error != null:
return error();case DataChannelEvent_BufferedAmountLow() when bufferedAmountLow != null:
return bufferedAmountLow();case DataChannelEvent_BufferedAmountHigh() when bufferedAmountHigh != null:
return bufferedAmountHigh();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  open,required TResult Function( Uint8List data,  bool isText)  message,required TResult Function()  closing,required TResult Function()  closed,required TResult Function()  error,required TResult Function()  bufferedAmountLow,required TResult Function()  bufferedAmountHigh,}) {final _that = this;
switch (_that) {
case DataChannelEvent_Open():
return open();case DataChannelEvent_Message():
return message(_that.data,_that.isText);case DataChannelEvent_Closing():
return closing();case DataChannelEvent_Closed():
return closed();case DataChannelEvent_Error():
return error();case DataChannelEvent_BufferedAmountLow():
return bufferedAmountLow();case DataChannelEvent_BufferedAmountHigh():
return bufferedAmountHigh();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  open,TResult? Function( Uint8List data,  bool isText)?  message,TResult? Function()?  closing,TResult? Function()?  closed,TResult? Function()?  error,TResult? Function()?  bufferedAmountLow,TResult? Function()?  bufferedAmountHigh,}) {final _that = this;
switch (_that) {
case DataChannelEvent_Open() when open != null:
return open();case DataChannelEvent_Message() when message != null:
return message(_that.data,_that.isText);case DataChannelEvent_Closing() when closing != null:
return closing();case DataChannelEvent_Closed() when closed != null:
return closed();case DataChannelEvent_Error() when error != null:
return error();case DataChannelEvent_BufferedAmountLow() when bufferedAmountLow != null:
return bufferedAmountLow();case DataChannelEvent_BufferedAmountHigh() when bufferedAmountHigh != null:
return bufferedAmountHigh();case _:
  return null;

}
}

}

/// @nodoc


class DataChannelEvent_Open extends DataChannelEvent {
  const DataChannelEvent_Open(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataChannelEvent_Open);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DataChannelEvent.open()';
}


}




/// @nodoc


class DataChannelEvent_Message extends DataChannelEvent {
  const DataChannelEvent_Message({required this.data, required this.isText}): super._();
  

 final  Uint8List data;
 final  bool isText;

/// Create a copy of DataChannelEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataChannelEvent_MessageCopyWith<DataChannelEvent_Message> get copyWith => _$DataChannelEvent_MessageCopyWithImpl<DataChannelEvent_Message>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataChannelEvent_Message&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.isText, isText) || other.isText == isText));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(data),isText);
}

@override
String toString() {
    return 'DataChannelEvent.message(data: $data, isText: $isText)';
}


}

/// @nodoc
abstract mixin class $DataChannelEvent_MessageCopyWith<$Res> implements $DataChannelEventCopyWith<$Res> {
  factory $DataChannelEvent_MessageCopyWith(DataChannelEvent_Message value, $Res Function(DataChannelEvent_Message) _then) = _$DataChannelEvent_MessageCopyWithImpl;
@useResult
$Res call({
 Uint8List data, bool isText
});




}
/// @nodoc
class _$DataChannelEvent_MessageCopyWithImpl<$Res>
    implements $DataChannelEvent_MessageCopyWith<$Res> {
  _$DataChannelEvent_MessageCopyWithImpl(this._self, this._then);

  final DataChannelEvent_Message _self;
  final $Res Function(DataChannelEvent_Message) _then;

/// Create a copy of DataChannelEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,Object? isText = null,}) {
  return _then(DataChannelEvent_Message(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Uint8List,isText: null == isText ? _self.isText : isText // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class DataChannelEvent_Closing extends DataChannelEvent {
  const DataChannelEvent_Closing(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataChannelEvent_Closing);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DataChannelEvent.closing()';
}


}




/// @nodoc


class DataChannelEvent_Closed extends DataChannelEvent {
  const DataChannelEvent_Closed(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataChannelEvent_Closed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DataChannelEvent.closed()';
}


}




/// @nodoc


class DataChannelEvent_Error extends DataChannelEvent {
  const DataChannelEvent_Error(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataChannelEvent_Error);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DataChannelEvent.error()';
}


}




/// @nodoc


class DataChannelEvent_BufferedAmountLow extends DataChannelEvent {
  const DataChannelEvent_BufferedAmountLow(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataChannelEvent_BufferedAmountLow);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DataChannelEvent.bufferedAmountLow()';
}


}




/// @nodoc


class DataChannelEvent_BufferedAmountHigh extends DataChannelEvent {
  const DataChannelEvent_BufferedAmountHigh(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DataChannelEvent_BufferedAmountHigh);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'DataChannelEvent.bufferedAmountHigh()';
}


}




/// @nodoc
mixin _$PeerConnectionEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PeerConnectionEvent()';
}


}

/// @nodoc
class $PeerConnectionEventCopyWith<$Res>  {
$PeerConnectionEventCopyWith(PeerConnectionEvent _, $Res Function(PeerConnectionEvent) __);
}


/// Adds pattern-matching-related methods to [PeerConnectionEvent].
extension PeerConnectionEventPatterns on PeerConnectionEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PeerConnectionEvent_ConnectionStateChanged value)?  connectionStateChanged,TResult Function( PeerConnectionEvent_IceGatheringStateChanged value)?  iceGatheringStateChanged,TResult Function( PeerConnectionEvent_IceConnectionStateChanged value)?  iceConnectionStateChanged,TResult Function( PeerConnectionEvent_SignalingStateChanged value)?  signalingStateChanged,TResult Function( PeerConnectionEvent_IceCandidate value)?  iceCandidate,TResult Function( PeerConnectionEvent_DataChannel value)?  dataChannel,TResult Function( PeerConnectionEvent_RemoteTrack value)?  remoteTrack,TResult Function( PeerConnectionEvent_NegotiationNeeded value)?  negotiationNeeded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PeerConnectionEvent_ConnectionStateChanged() when connectionStateChanged != null:
return connectionStateChanged(_that);case PeerConnectionEvent_IceGatheringStateChanged() when iceGatheringStateChanged != null:
return iceGatheringStateChanged(_that);case PeerConnectionEvent_IceConnectionStateChanged() when iceConnectionStateChanged != null:
return iceConnectionStateChanged(_that);case PeerConnectionEvent_SignalingStateChanged() when signalingStateChanged != null:
return signalingStateChanged(_that);case PeerConnectionEvent_IceCandidate() when iceCandidate != null:
return iceCandidate(_that);case PeerConnectionEvent_DataChannel() when dataChannel != null:
return dataChannel(_that);case PeerConnectionEvent_RemoteTrack() when remoteTrack != null:
return remoteTrack(_that);case PeerConnectionEvent_NegotiationNeeded() when negotiationNeeded != null:
return negotiationNeeded(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PeerConnectionEvent_ConnectionStateChanged value)  connectionStateChanged,required TResult Function( PeerConnectionEvent_IceGatheringStateChanged value)  iceGatheringStateChanged,required TResult Function( PeerConnectionEvent_IceConnectionStateChanged value)  iceConnectionStateChanged,required TResult Function( PeerConnectionEvent_SignalingStateChanged value)  signalingStateChanged,required TResult Function( PeerConnectionEvent_IceCandidate value)  iceCandidate,required TResult Function( PeerConnectionEvent_DataChannel value)  dataChannel,required TResult Function( PeerConnectionEvent_RemoteTrack value)  remoteTrack,required TResult Function( PeerConnectionEvent_NegotiationNeeded value)  negotiationNeeded,}){
final _that = this;
switch (_that) {
case PeerConnectionEvent_ConnectionStateChanged():
return connectionStateChanged(_that);case PeerConnectionEvent_IceGatheringStateChanged():
return iceGatheringStateChanged(_that);case PeerConnectionEvent_IceConnectionStateChanged():
return iceConnectionStateChanged(_that);case PeerConnectionEvent_SignalingStateChanged():
return signalingStateChanged(_that);case PeerConnectionEvent_IceCandidate():
return iceCandidate(_that);case PeerConnectionEvent_DataChannel():
return dataChannel(_that);case PeerConnectionEvent_RemoteTrack():
return remoteTrack(_that);case PeerConnectionEvent_NegotiationNeeded():
return negotiationNeeded(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PeerConnectionEvent_ConnectionStateChanged value)?  connectionStateChanged,TResult? Function( PeerConnectionEvent_IceGatheringStateChanged value)?  iceGatheringStateChanged,TResult? Function( PeerConnectionEvent_IceConnectionStateChanged value)?  iceConnectionStateChanged,TResult? Function( PeerConnectionEvent_SignalingStateChanged value)?  signalingStateChanged,TResult? Function( PeerConnectionEvent_IceCandidate value)?  iceCandidate,TResult? Function( PeerConnectionEvent_DataChannel value)?  dataChannel,TResult? Function( PeerConnectionEvent_RemoteTrack value)?  remoteTrack,TResult? Function( PeerConnectionEvent_NegotiationNeeded value)?  negotiationNeeded,}){
final _that = this;
switch (_that) {
case PeerConnectionEvent_ConnectionStateChanged() when connectionStateChanged != null:
return connectionStateChanged(_that);case PeerConnectionEvent_IceGatheringStateChanged() when iceGatheringStateChanged != null:
return iceGatheringStateChanged(_that);case PeerConnectionEvent_IceConnectionStateChanged() when iceConnectionStateChanged != null:
return iceConnectionStateChanged(_that);case PeerConnectionEvent_SignalingStateChanged() when signalingStateChanged != null:
return signalingStateChanged(_that);case PeerConnectionEvent_IceCandidate() when iceCandidate != null:
return iceCandidate(_that);case PeerConnectionEvent_DataChannel() when dataChannel != null:
return dataChannel(_that);case PeerConnectionEvent_RemoteTrack() when remoteTrack != null:
return remoteTrack(_that);case PeerConnectionEvent_NegotiationNeeded() when negotiationNeeded != null:
return negotiationNeeded(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( PeerConnectionState field0)?  connectionStateChanged,TResult Function( IceGatheringState field0)?  iceGatheringStateChanged,TResult Function( IceConnectionState field0)?  iceConnectionStateChanged,TResult Function( SignalingState field0)?  signalingStateChanged,TResult Function( String candidateJson)?  iceCandidate,TResult Function( String channelId)?  dataChannel,TResult Function( String trackId,  MediaKind kind,  String mimeType)?  remoteTrack,TResult Function()?  negotiationNeeded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PeerConnectionEvent_ConnectionStateChanged() when connectionStateChanged != null:
return connectionStateChanged(_that.field0);case PeerConnectionEvent_IceGatheringStateChanged() when iceGatheringStateChanged != null:
return iceGatheringStateChanged(_that.field0);case PeerConnectionEvent_IceConnectionStateChanged() when iceConnectionStateChanged != null:
return iceConnectionStateChanged(_that.field0);case PeerConnectionEvent_SignalingStateChanged() when signalingStateChanged != null:
return signalingStateChanged(_that.field0);case PeerConnectionEvent_IceCandidate() when iceCandidate != null:
return iceCandidate(_that.candidateJson);case PeerConnectionEvent_DataChannel() when dataChannel != null:
return dataChannel(_that.channelId);case PeerConnectionEvent_RemoteTrack() when remoteTrack != null:
return remoteTrack(_that.trackId,_that.kind,_that.mimeType);case PeerConnectionEvent_NegotiationNeeded() when negotiationNeeded != null:
return negotiationNeeded();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( PeerConnectionState field0)  connectionStateChanged,required TResult Function( IceGatheringState field0)  iceGatheringStateChanged,required TResult Function( IceConnectionState field0)  iceConnectionStateChanged,required TResult Function( SignalingState field0)  signalingStateChanged,required TResult Function( String candidateJson)  iceCandidate,required TResult Function( String channelId)  dataChannel,required TResult Function( String trackId,  MediaKind kind,  String mimeType)  remoteTrack,required TResult Function()  negotiationNeeded,}) {final _that = this;
switch (_that) {
case PeerConnectionEvent_ConnectionStateChanged():
return connectionStateChanged(_that.field0);case PeerConnectionEvent_IceGatheringStateChanged():
return iceGatheringStateChanged(_that.field0);case PeerConnectionEvent_IceConnectionStateChanged():
return iceConnectionStateChanged(_that.field0);case PeerConnectionEvent_SignalingStateChanged():
return signalingStateChanged(_that.field0);case PeerConnectionEvent_IceCandidate():
return iceCandidate(_that.candidateJson);case PeerConnectionEvent_DataChannel():
return dataChannel(_that.channelId);case PeerConnectionEvent_RemoteTrack():
return remoteTrack(_that.trackId,_that.kind,_that.mimeType);case PeerConnectionEvent_NegotiationNeeded():
return negotiationNeeded();}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( PeerConnectionState field0)?  connectionStateChanged,TResult? Function( IceGatheringState field0)?  iceGatheringStateChanged,TResult? Function( IceConnectionState field0)?  iceConnectionStateChanged,TResult? Function( SignalingState field0)?  signalingStateChanged,TResult? Function( String candidateJson)?  iceCandidate,TResult? Function( String channelId)?  dataChannel,TResult? Function( String trackId,  MediaKind kind,  String mimeType)?  remoteTrack,TResult? Function()?  negotiationNeeded,}) {final _that = this;
switch (_that) {
case PeerConnectionEvent_ConnectionStateChanged() when connectionStateChanged != null:
return connectionStateChanged(_that.field0);case PeerConnectionEvent_IceGatheringStateChanged() when iceGatheringStateChanged != null:
return iceGatheringStateChanged(_that.field0);case PeerConnectionEvent_IceConnectionStateChanged() when iceConnectionStateChanged != null:
return iceConnectionStateChanged(_that.field0);case PeerConnectionEvent_SignalingStateChanged() when signalingStateChanged != null:
return signalingStateChanged(_that.field0);case PeerConnectionEvent_IceCandidate() when iceCandidate != null:
return iceCandidate(_that.candidateJson);case PeerConnectionEvent_DataChannel() when dataChannel != null:
return dataChannel(_that.channelId);case PeerConnectionEvent_RemoteTrack() when remoteTrack != null:
return remoteTrack(_that.trackId,_that.kind,_that.mimeType);case PeerConnectionEvent_NegotiationNeeded() when negotiationNeeded != null:
return negotiationNeeded();case _:
  return null;

}
}

}

/// @nodoc


class PeerConnectionEvent_ConnectionStateChanged extends PeerConnectionEvent {
  const PeerConnectionEvent_ConnectionStateChanged(this.field0): super._();
  

 final  PeerConnectionState field0;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_ConnectionStateChangedCopyWith<PeerConnectionEvent_ConnectionStateChanged> get copyWith => _$PeerConnectionEvent_ConnectionStateChangedCopyWithImpl<PeerConnectionEvent_ConnectionStateChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_ConnectionStateChanged&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'PeerConnectionEvent.connectionStateChanged(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_ConnectionStateChangedCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_ConnectionStateChangedCopyWith(PeerConnectionEvent_ConnectionStateChanged value, $Res Function(PeerConnectionEvent_ConnectionStateChanged) _then) = _$PeerConnectionEvent_ConnectionStateChangedCopyWithImpl;
@useResult
$Res call({
 PeerConnectionState field0
});




}
/// @nodoc
class _$PeerConnectionEvent_ConnectionStateChangedCopyWithImpl<$Res>
    implements $PeerConnectionEvent_ConnectionStateChangedCopyWith<$Res> {
  _$PeerConnectionEvent_ConnectionStateChangedCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_ConnectionStateChanged _self;
  final $Res Function(PeerConnectionEvent_ConnectionStateChanged) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PeerConnectionEvent_ConnectionStateChanged(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as PeerConnectionState,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_IceGatheringStateChanged extends PeerConnectionEvent {
  const PeerConnectionEvent_IceGatheringStateChanged(this.field0): super._();
  

 final  IceGatheringState field0;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_IceGatheringStateChangedCopyWith<PeerConnectionEvent_IceGatheringStateChanged> get copyWith => _$PeerConnectionEvent_IceGatheringStateChangedCopyWithImpl<PeerConnectionEvent_IceGatheringStateChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_IceGatheringStateChanged&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'PeerConnectionEvent.iceGatheringStateChanged(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_IceGatheringStateChangedCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_IceGatheringStateChangedCopyWith(PeerConnectionEvent_IceGatheringStateChanged value, $Res Function(PeerConnectionEvent_IceGatheringStateChanged) _then) = _$PeerConnectionEvent_IceGatheringStateChangedCopyWithImpl;
@useResult
$Res call({
 IceGatheringState field0
});




}
/// @nodoc
class _$PeerConnectionEvent_IceGatheringStateChangedCopyWithImpl<$Res>
    implements $PeerConnectionEvent_IceGatheringStateChangedCopyWith<$Res> {
  _$PeerConnectionEvent_IceGatheringStateChangedCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_IceGatheringStateChanged _self;
  final $Res Function(PeerConnectionEvent_IceGatheringStateChanged) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PeerConnectionEvent_IceGatheringStateChanged(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as IceGatheringState,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_IceConnectionStateChanged extends PeerConnectionEvent {
  const PeerConnectionEvent_IceConnectionStateChanged(this.field0): super._();
  

 final  IceConnectionState field0;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_IceConnectionStateChangedCopyWith<PeerConnectionEvent_IceConnectionStateChanged> get copyWith => _$PeerConnectionEvent_IceConnectionStateChangedCopyWithImpl<PeerConnectionEvent_IceConnectionStateChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_IceConnectionStateChanged&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'PeerConnectionEvent.iceConnectionStateChanged(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_IceConnectionStateChangedCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_IceConnectionStateChangedCopyWith(PeerConnectionEvent_IceConnectionStateChanged value, $Res Function(PeerConnectionEvent_IceConnectionStateChanged) _then) = _$PeerConnectionEvent_IceConnectionStateChangedCopyWithImpl;
@useResult
$Res call({
 IceConnectionState field0
});




}
/// @nodoc
class _$PeerConnectionEvent_IceConnectionStateChangedCopyWithImpl<$Res>
    implements $PeerConnectionEvent_IceConnectionStateChangedCopyWith<$Res> {
  _$PeerConnectionEvent_IceConnectionStateChangedCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_IceConnectionStateChanged _self;
  final $Res Function(PeerConnectionEvent_IceConnectionStateChanged) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PeerConnectionEvent_IceConnectionStateChanged(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as IceConnectionState,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_SignalingStateChanged extends PeerConnectionEvent {
  const PeerConnectionEvent_SignalingStateChanged(this.field0): super._();
  

 final  SignalingState field0;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_SignalingStateChangedCopyWith<PeerConnectionEvent_SignalingStateChanged> get copyWith => _$PeerConnectionEvent_SignalingStateChangedCopyWithImpl<PeerConnectionEvent_SignalingStateChanged>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_SignalingStateChanged&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode {
    return Object.hash(runtimeType,field0);
}

@override
String toString() {
    return 'PeerConnectionEvent.signalingStateChanged(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_SignalingStateChangedCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_SignalingStateChangedCopyWith(PeerConnectionEvent_SignalingStateChanged value, $Res Function(PeerConnectionEvent_SignalingStateChanged) _then) = _$PeerConnectionEvent_SignalingStateChangedCopyWithImpl;
@useResult
$Res call({
 SignalingState field0
});




}
/// @nodoc
class _$PeerConnectionEvent_SignalingStateChangedCopyWithImpl<$Res>
    implements $PeerConnectionEvent_SignalingStateChangedCopyWith<$Res> {
  _$PeerConnectionEvent_SignalingStateChangedCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_SignalingStateChanged _self;
  final $Res Function(PeerConnectionEvent_SignalingStateChanged) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(PeerConnectionEvent_SignalingStateChanged(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as SignalingState,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_IceCandidate extends PeerConnectionEvent {
  const PeerConnectionEvent_IceCandidate({required this.candidateJson}): super._();
  

 final  String candidateJson;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_IceCandidateCopyWith<PeerConnectionEvent_IceCandidate> get copyWith => _$PeerConnectionEvent_IceCandidateCopyWithImpl<PeerConnectionEvent_IceCandidate>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_IceCandidate&&(identical(other.candidateJson, candidateJson) || other.candidateJson == candidateJson));
}


@override
int get hashCode {
    return Object.hash(runtimeType,candidateJson);
}

@override
String toString() {
    return 'PeerConnectionEvent.iceCandidate(candidateJson: $candidateJson)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_IceCandidateCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_IceCandidateCopyWith(PeerConnectionEvent_IceCandidate value, $Res Function(PeerConnectionEvent_IceCandidate) _then) = _$PeerConnectionEvent_IceCandidateCopyWithImpl;
@useResult
$Res call({
 String candidateJson
});




}
/// @nodoc
class _$PeerConnectionEvent_IceCandidateCopyWithImpl<$Res>
    implements $PeerConnectionEvent_IceCandidateCopyWith<$Res> {
  _$PeerConnectionEvent_IceCandidateCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_IceCandidate _self;
  final $Res Function(PeerConnectionEvent_IceCandidate) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? candidateJson = null,}) {
  return _then(PeerConnectionEvent_IceCandidate(
candidateJson: null == candidateJson ? _self.candidateJson : candidateJson // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_DataChannel extends PeerConnectionEvent {
  const PeerConnectionEvent_DataChannel({required this.channelId}): super._();
  

 final  String channelId;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_DataChannelCopyWith<PeerConnectionEvent_DataChannel> get copyWith => _$PeerConnectionEvent_DataChannelCopyWithImpl<PeerConnectionEvent_DataChannel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_DataChannel&&(identical(other.channelId, channelId) || other.channelId == channelId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,channelId);
}

@override
String toString() {
    return 'PeerConnectionEvent.dataChannel(channelId: $channelId)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_DataChannelCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_DataChannelCopyWith(PeerConnectionEvent_DataChannel value, $Res Function(PeerConnectionEvent_DataChannel) _then) = _$PeerConnectionEvent_DataChannelCopyWithImpl;
@useResult
$Res call({
 String channelId
});




}
/// @nodoc
class _$PeerConnectionEvent_DataChannelCopyWithImpl<$Res>
    implements $PeerConnectionEvent_DataChannelCopyWith<$Res> {
  _$PeerConnectionEvent_DataChannelCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_DataChannel _self;
  final $Res Function(PeerConnectionEvent_DataChannel) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? channelId = null,}) {
  return _then(PeerConnectionEvent_DataChannel(
channelId: null == channelId ? _self.channelId : channelId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_RemoteTrack extends PeerConnectionEvent {
  const PeerConnectionEvent_RemoteTrack({required this.trackId, required this.kind, required this.mimeType}): super._();
  

 final  String trackId;
 final  MediaKind kind;
 final  String mimeType;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeerConnectionEvent_RemoteTrackCopyWith<PeerConnectionEvent_RemoteTrack> get copyWith => _$PeerConnectionEvent_RemoteTrackCopyWithImpl<PeerConnectionEvent_RemoteTrack>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_RemoteTrack&&(identical(other.trackId, trackId) || other.trackId == trackId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType));
}


@override
int get hashCode {
    return Object.hash(runtimeType,trackId,kind,mimeType);
}

@override
String toString() {
    return 'PeerConnectionEvent.remoteTrack(trackId: $trackId, kind: $kind, mimeType: $mimeType)';
}


}

/// @nodoc
abstract mixin class $PeerConnectionEvent_RemoteTrackCopyWith<$Res> implements $PeerConnectionEventCopyWith<$Res> {
  factory $PeerConnectionEvent_RemoteTrackCopyWith(PeerConnectionEvent_RemoteTrack value, $Res Function(PeerConnectionEvent_RemoteTrack) _then) = _$PeerConnectionEvent_RemoteTrackCopyWithImpl;
@useResult
$Res call({
 String trackId, MediaKind kind, String mimeType
});




}
/// @nodoc
class _$PeerConnectionEvent_RemoteTrackCopyWithImpl<$Res>
    implements $PeerConnectionEvent_RemoteTrackCopyWith<$Res> {
  _$PeerConnectionEvent_RemoteTrackCopyWithImpl(this._self, this._then);

  final PeerConnectionEvent_RemoteTrack _self;
  final $Res Function(PeerConnectionEvent_RemoteTrack) _then;

/// Create a copy of PeerConnectionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? trackId = null,Object? kind = null,Object? mimeType = null,}) {
  return _then(PeerConnectionEvent_RemoteTrack(
trackId: null == trackId ? _self.trackId : trackId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as MediaKind,mimeType: null == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PeerConnectionEvent_NegotiationNeeded extends PeerConnectionEvent {
  const PeerConnectionEvent_NegotiationNeeded(): super._();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PeerConnectionEvent_NegotiationNeeded);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'PeerConnectionEvent.negotiationNeeded()';
}


}




// dart format on
