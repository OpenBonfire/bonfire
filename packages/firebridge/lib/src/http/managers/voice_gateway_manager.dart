abstract class VoiceGatewayManager {
  /// @nodoc
  // We need a constructor to be allowed to use this class as a superclass.
  VoiceGatewayManager.create();

  factory VoiceGatewayManager() = _VoiceGatewayManagerImpl;
}

class _VoiceGatewayManagerImpl extends VoiceGatewayManager {
  _VoiceGatewayManagerImpl() : super.create();
}
