import AVFoundation
import Foundation

func listInputs() throws -> [Device] {
  var devices: [Device] = []

  listInputDevices().forEach { input in
    let deviceID = getAudioDeviceIDFromUID(uid: input.uniqueID)
    let type = deviceID.map { getInputTransportType(deviceID: $0) } ?? "unknown"
    let sampleRates = deviceID.map { getInputSampleRates(deviceID: $0) } ?? []
    devices.append(Device(id: input.uniqueID, label: input.localizedName, type: type, sampleRates: sampleRates))
  }

  return devices
}

func getInputTransportType(deviceID: AudioDeviceID) -> String {
  var addr = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyTransportType,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  var transportType: UInt32 = 0
  var size = UInt32(MemoryLayout<UInt32>.size)
  guard AudioObjectGetPropertyData(deviceID, &addr, 0, nil, &size, &transportType) == noErr else { return "unknown" }

  switch transportType {
  case kAudioDeviceTransportTypeBuiltIn:     return "builtIn"
  case kAudioDeviceTransportTypeUSB:         return "usb"
  case kAudioDeviceTransportTypeBluetooth:   return "bluetoothSco"
  case kAudioDeviceTransportTypeBluetoothLE: return "bluetoothLe"
  case kAudioDeviceTransportTypeHDMI:        return "hdmi"
  case kAudioDeviceTransportTypeDisplayPort: return "displayPort"
  case kAudioDeviceTransportTypeAirPlay:     return "airPlay"
  case kAudioDeviceTransportTypeThunderbolt: return "thunderbolt"
  default:                                   return "unknown"
  }
}

func listInputDevices() -> [AVCaptureDevice] {
  var deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInMicrophone, .externalUnknown]
  
  if #available(macOS 14.0, *) {
    deviceTypes.append(.microphone)
  }

  let discoverySession = AVCaptureDevice.DiscoverySession(
    deviceTypes: deviceTypes,
    mediaType: .audio, position: .unspecified
  )
  
  return discoverySession.devices
}

func getInputDevice(device: Device?) throws -> AVCaptureDeviceInput? {
  guard let device = device else {
    // try to select default device
    let defaultDevice = AVCaptureDevice.default(for: .audio)
    guard let defaultDevice = defaultDevice else {
      return nil
    }
    
    return try AVCaptureDeviceInput(device: defaultDevice)
  }

  // find the given device
  let devs = listInputDevices()
  let captureDev = devs.first { dev in
    dev.uniqueID == device.id
  }
  guard let captureDev = captureDev else {
    return nil
  }
  
  return try AVCaptureDeviceInput(device: captureDev)
}

func getInputChannelCount(device: Device?) -> Int? {
  guard let deviceID = resolveInputDeviceID(device: device) else { return nil }

  var addr = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyStreamConfiguration,
    mScope: kAudioDevicePropertyScopeInput,
    mElement: kAudioObjectPropertyElementMain
  )
  var size: UInt32 = 0
  guard AudioObjectGetPropertyDataSize(deviceID, &addr, 0, nil, &size) == noErr, size > 0 else { return nil }

  let bufferList = UnsafeMutablePointer<AudioBufferList>.allocate(capacity: Int(size))
  defer { bufferList.deallocate() }
  guard AudioObjectGetPropertyData(deviceID, &addr, 0, nil, &size, bufferList) == noErr else { return nil }

  let total = UnsafeMutableAudioBufferListPointer(bufferList).reduce(0) { $0 + Int($1.mNumberChannels) }
  return total > 0 ? total : nil
}

func getInputSampleRates(deviceID: AudioDeviceID) -> [Int] {
  var addr = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyAvailableNominalSampleRates,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  var size: UInt32 = 0
  guard AudioObjectGetPropertyDataSize(deviceID, &addr, 0, nil, &size) == noErr, size > 0 else { return [] }

  let count = Int(size) / MemoryLayout<AudioValueRange>.size
  var ranges = [AudioValueRange](repeating: AudioValueRange(), count: count)
  guard AudioObjectGetPropertyData(deviceID, &addr, 0, nil, &size, &ranges) == noErr else { return [] }

  var rates = Set<Int>()
  for range in ranges {
    rates.insert(Int(range.mMinimum))
    if range.mMinimum != range.mMaximum { rates.insert(Int(range.mMaximum)) }
  }
  return rates.sorted()
}

func getInputSampleRate(device: Device?) -> Double? {
  guard let deviceID = resolveInputDeviceID(device: device) else { return nil }

  var addr = AudioObjectPropertyAddress(
    mSelector: kAudioDevicePropertyNominalSampleRate,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  var rate: Float64 = 0
  var size = UInt32(MemoryLayout<Float64>.size)
  guard AudioObjectGetPropertyData(deviceID, &addr, 0, nil, &size, &rate) == noErr, rate > 0 else { return nil }
  return rate
}

private func resolveInputDeviceID(device: Device?) -> AudioDeviceID? {
  if let uid = device?.id {
    return getAudioDeviceIDFromUID(uid: uid)
  }
  var addr = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDefaultInputDevice,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  var deviceID: AudioDeviceID = kAudioObjectUnknown
  var size = UInt32(MemoryLayout<AudioDeviceID>.size)
  guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &addr, 0, nil, &size, &deviceID) == noErr else {
    return nil
  }
  return deviceID
}

func getAudioDeviceIDFromUID(uid: String) -> AudioDeviceID? {
  var propertySize: UInt32 = 0
  var status: OSStatus = noErr
  
  // Get the number of devices
  var propertyAddress = AudioObjectPropertyAddress(
    mSelector: kAudioHardwarePropertyDevices,
    mScope: kAudioObjectPropertyScopeGlobal,
    mElement: kAudioObjectPropertyElementMain
  )
  status = AudioObjectGetPropertyDataSize(
    AudioObjectID(kAudioObjectSystemObject),
    &propertyAddress,
    0,
    nil,
    &propertySize
  )
  if status != noErr {
    return nil
  }
  
  // Get the device IDs
  let deviceCount = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
  var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)
  status = AudioObjectGetPropertyData(
    AudioObjectID(kAudioObjectSystemObject),
    &propertyAddress,
    0,
    nil,
    &propertySize,
    &deviceIDs
  )
  if status != noErr {
    return nil
  }

  // Get device UID
  for deviceID in deviceIDs {
    // Support lookup by devicezID rather than uid
    if String(deviceID) == uid {
      return deviceID
    }

    propertyAddress.mSelector = kAudioDevicePropertyDeviceUID
    propertySize = UInt32(MemoryLayout<CFString>.size)
    var deviceUID: Unmanaged<CFString>?

    status = AudioObjectGetPropertyData(
      deviceID,
      &propertyAddress,
      0,
      nil,
      &propertySize,
      &deviceUID
    )
    if status == noErr && uid == deviceUID?.takeRetainedValue() as String? {
      return deviceID
    }
  }
  
  return nil
}
