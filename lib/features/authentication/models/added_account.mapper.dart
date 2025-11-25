// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'added_account.dart';

class AddedAccountMapper extends ClassMapperBase<AddedAccount> {
  AddedAccountMapper._();

  static AddedAccountMapper? _instance;
  static AddedAccountMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AddedAccountMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AddedAccount';

  static String _$token(AddedAccount v) => v.token;
  static const Field<AddedAccount, String> _f$token = Field('token', _$token);
  static String _$username(AddedAccount v) => v.username;
  static const Field<AddedAccount, String> _f$username = Field(
    'username',
    _$username,
  );
  static String _$userId(AddedAccount v) => v.userId;
  static const Field<AddedAccount, String> _f$userId = Field(
    'userId',
    _$userId,
  );
  static String _$avatar(AddedAccount v) => v.avatar;
  static const Field<AddedAccount, String> _f$avatar = Field(
    'avatar',
    _$avatar,
  );

  @override
  final MappableFields<AddedAccount> fields = const {
    #token: _f$token,
    #username: _f$username,
    #userId: _f$userId,
    #avatar: _f$avatar,
  };

  static AddedAccount _instantiate(DecodingData data) {
    return AddedAccount(
      token: data.dec(_f$token),
      username: data.dec(_f$username),
      userId: data.dec(_f$userId),
      avatar: data.dec(_f$avatar),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static AddedAccount fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AddedAccount>(map);
  }

  static AddedAccount fromJson(String json) {
    return ensureInitialized().decodeJson<AddedAccount>(json);
  }
}

mixin AddedAccountMappable {
  String toJson() {
    return AddedAccountMapper.ensureInitialized().encodeJson<AddedAccount>(
      this as AddedAccount,
    );
  }

  Map<String, dynamic> toMap() {
    return AddedAccountMapper.ensureInitialized().encodeMap<AddedAccount>(
      this as AddedAccount,
    );
  }

  AddedAccountCopyWith<AddedAccount, AddedAccount, AddedAccount> get copyWith =>
      _AddedAccountCopyWithImpl<AddedAccount, AddedAccount>(
        this as AddedAccount,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AddedAccountMapper.ensureInitialized().stringifyValue(
      this as AddedAccount,
    );
  }

  @override
  bool operator ==(Object other) {
    return AddedAccountMapper.ensureInitialized().equalsValue(
      this as AddedAccount,
      other,
    );
  }

  @override
  int get hashCode {
    return AddedAccountMapper.ensureInitialized().hashValue(
      this as AddedAccount,
    );
  }
}

extension AddedAccountValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AddedAccount, $Out> {
  AddedAccountCopyWith<$R, AddedAccount, $Out> get $asAddedAccount =>
      $base.as((v, t, t2) => _AddedAccountCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AddedAccountCopyWith<$R, $In extends AddedAccount, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? token, String? username, String? userId, String? avatar});
  AddedAccountCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _AddedAccountCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AddedAccount, $Out>
    implements AddedAccountCopyWith<$R, AddedAccount, $Out> {
  _AddedAccountCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AddedAccount> $mapper =
      AddedAccountMapper.ensureInitialized();
  @override
  $R call({String? token, String? username, String? userId, String? avatar}) =>
      $apply(
        FieldCopyWithData({
          if (token != null) #token: token,
          if (username != null) #username: username,
          if (userId != null) #userId: userId,
          if (avatar != null) #avatar: avatar,
        }),
      );
  @override
  AddedAccount $make(CopyWithData data) => AddedAccount(
    token: data.get(#token, or: $value.token),
    username: data.get(#username, or: $value.username),
    userId: data.get(#userId, or: $value.userId),
    avatar: data.get(#avatar, or: $value.avatar),
  );

  @override
  AddedAccountCopyWith<$R2, AddedAccount, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _AddedAccountCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

