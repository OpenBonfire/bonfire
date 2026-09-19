import Foundation
import AVFoundation
import FlutterMacOS

class Recorder {
  private let minAmplitudeDB: Float = -160.0
  private var m_maxAmplitude: Float = -160.0
  private var m_state: RecordState = .stop

  private let m_queue: DispatchQueue

  private var m_stateEventHandler: StateStreamHandler
  private var m_recordEventHandler: RecordStreamHandler

  private var m_delegate: AudioRecordingDelegate?
  private var m_configChangedChannel: FlutterMethodChannel?

  init(queue: DispatchQueue, stateEventHandler: StateStreamHandler, recordEventHandler: RecordStreamHandler, configChangedChannel: FlutterMethodChannel? = nil) {
    m_queue = queue
    m_stateEventHandler = stateEventHandler
    m_recordEventHandler = recordEventHandler
    m_configChangedChannel = configChangedChannel
  }

  // MARK: - All methods below are called on m_queue (via withRecorder in the plugin)

  func dispose() {
    _ = stop()
  }

  func start(config: RecordConfig, path: String) throws {
    _ = stop()

    guard isEncoderSupported(config.encoder) else {
      throw RecorderError.error(message: "Failed to start recording", details: "\(config.encoder) not supported.")
    }

    let delegate = RecorderFileDelegate(
      queue: m_queue,
      onRecord: { [weak self] in self?.updateState(.record) },
      onPause:  { [weak self] in self?.updateState(.pause)  },
      onStop:   { [weak self] in self?.updateState(.stop)   }
    )
    try delegate.start(config: config, path: path)
    m_delegate = delegate

    if config.isModified { notifyConfigChanged(config) }
  }

  func startStream(config: RecordConfig) throws {
    _ = stop()

    guard config.encoder == AudioEncoder.pcm16bits.rawValue || config.encoder == AudioEncoder.aacLc.rawValue else {
      throw RecorderError.error(message: "Failed to start recording", details: "\(config.encoder) not supported in streaming mode.")
    }

    let delegate = RecorderStreamDelegate(
      queue: m_queue,
      onRecord: { [weak self] in self?.updateState(.record) },
      onPause:  { [weak self] in self?.updateState(.pause)  },
      onStop:   { [weak self] in self?.updateState(.stop)   }
    )
    try delegate.start(config: config, recordEventHandler: m_recordEventHandler)
    m_delegate = delegate

    if config.isModified { notifyConfigChanged(config) }
  }

  @discardableResult
  func stop() -> String? {
    guard m_state != .stop else { return nil }
    let path = m_delegate?.stop()
    m_maxAmplitude = minAmplitudeDB
    return path
  }

  func pause() {
    guard m_state == .record else { return }
    m_delegate?.pause()
  }

  func resume() throws {
    guard m_state == .pause else { return }
    try m_delegate?.resume()
  }

  func isPaused() -> Bool { m_state == .pause }
  func isRecording() -> Bool { m_state != .stop }

  func listInputDevices() throws -> [Device] { try listInputs() }

  func getAmplitude() -> [String: Float] {
    var amp = ["current": minAmplitudeDB, "max": minAmplitudeDB]
    if let current = m_delegate?.getAmplitude() {
      if current > m_maxAmplitude { m_maxAmplitude = current }
      amp["current"] = min(0.0, max(current, minAmplitudeDB))
      amp["max"]     = min(0.0, max(m_maxAmplitude, minAmplitudeDB))
    }
    return amp
  }

  func cancel() throws {
    guard m_state != .stop else { return }
    try m_delegate?.cancel()
  }

  func isEncoderSupported(_ encoder: String) -> Bool {
    switch encoder {
    case AudioEncoder.aacLc.rawValue,
         AudioEncoder.aacEld.rawValue,
         AudioEncoder.flac.rawValue,
         AudioEncoder.opus.rawValue,
         AudioEncoder.pcm16bits.rawValue,
         AudioEncoder.wav.rawValue:
      return true
    default:
      return false
    }
  }

  // MARK: - Private

  private func notifyConfigChanged(_ config: RecordConfig) {
    let args = config.toMap()
    DispatchQueue.main.async { [weak self] in
      self?.m_configChangedChannel?.invokeMethod("onConfigChanged", arguments: args)
    }
  }

  private func updateState(_ state: RecordState) {
    guard m_state != state else { return }
    m_state = state
    if let sink = m_stateEventHandler.eventSink {
      DispatchQueue.main.async { sink(state.rawValue) }
    }
  }
}
