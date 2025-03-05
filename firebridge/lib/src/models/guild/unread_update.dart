import 'package:firebridge/firebridge.dart';
import 'package:firebridge/src/utils/to_string_helper/base_impl.dart';

class ChannelUnreadUpdate with ToStringHelper {
  final ReadState readState;

  ChannelUnreadUpdate({required this.readState});
}
