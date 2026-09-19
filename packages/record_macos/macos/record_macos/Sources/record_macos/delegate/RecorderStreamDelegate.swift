import AVFoundation
import Foundation
import FlutterMacOS

class RecorderStreamDelegate: NSObject, AudioRecordingStreamDelegate {
  var config: RecordConfig?

  private var m_audioEngine: AVAudioEngine?
  private var m_processor: AudioStreamProcessor?
  private var m_isPaused = false
  private let m_lock = NSLock()
  private let m_bus = 0
  private let m_queue: DispatchQueue
  private var m_onRecord: () -> ()
  private var m_onPause:  () -> ()
  private var m_onStop:   () -> ()

  init(
    queue: DispatchQueue,
    onRecord: @escaping () -> (),
    onPause:  @escaping () -> (),
    onStop:   @escaping () -> ()
  ) {
    m_queue = queue
    m_onRecord = onRecord
    m_onPause  = onPause
    m_onStop   = onStop
  }

  func start(config: RecordConfig, recordEventHandler: RecordStreamHandler) throws {
    let engine = AVAudioEngine()

    if let deviceId = config.device?.id,
       let inputDeviceId = getAudioDeviceIDFromUID(uid: deviceId) {
      do {
        try engine.inputNode.auAudioUnit.setDeviceID(inputDeviceId)
      } catch {
        throw RecorderError.error(
          message: "Failed to start recording",
          details: "Setting input device: \(deviceId) \(error)"
        )
      }
    }

    try setVoiceProcessing(echoCancel: config.echoCancel, autoGain: config.autoGain, audioEngine: engine)

    let srcFormat = engine.inputNode.inputFormat(forBus: 0)
    let processor = try AudioStreamProcessor(config: config, srcFormat: srcFormat)

    engine.inputNode.installTap(
      onBus: m_bus,
      bufferSize: AVAudioFrameCount(config.streamBufferSize ?? 1024),
      format: srcFormat
    ) { [weak self] buffer, _ in
      self?.handleTap(buffer: buffer, recordEventHandler: recordEventHandler)
    }

    engine.prepare()
    do {
      try engine.start()
    } catch {
      processor.dispose()
      throw error
    }

    m_audioEngine = engine
    m_lock.withLock { m_processor = processor }
    self.config = config
    m_onRecord()
  }

  @discardableResult
  func stop() -> String? {
    if let engine = m_audioEngine {
      do { try setVoiceProcessing(echoCancel: false, autoGain: false, audioEngine: engine) } catch {}
      engine.inputNode.removeTap(onBus: m_bus)
      engine.stop()
    }
    m_audioEngine = nil

    m_lock.withLock {
      m_isPaused = false
      m_processor?.dispose()
      m_processor = nil
    }

    config = nil
    m_onStop()
    return nil
  }

  func pause() {
    m_lock.withLock { m_isPaused = true }
    m_audioEngine?.pause()
    m_onPause()
  }

  func resume() throws {
    try m_audioEngine?.start()
    m_lock.withLock { m_isPaused = false }
    m_onRecord()
  }

  func cancel() throws { _ = stop() }

  func getAmplitude() -> Float {
    m_lock.withLock { m_processor?.getAmplitude() ?? -160.0 }
  }

  func dispose() { _ = stop() }

  // MARK: - Private

  private func handleTap(buffer: AVAudioPCMBuffer, recordEventHandler: RecordStreamHandler) {
    let processor = m_lock.withLock { m_isPaused ? nil : m_processor }

    guard let processor else { return }

    guard let dataList = processor.process(buffer: buffer) else {
      let toDispose = m_lock.withLock { () -> AudioStreamProcessor? in
        let p = m_processor
        m_processor = nil
        return p
      }
      guard toDispose != nil else { return }
      m_queue.async {
        toDispose?.dispose()
        self.stop()
      }
      return
    }

    guard let sink = recordEventHandler.eventSink else { return }
    for data in dataList {
      DispatchQueue.main.async { sink(FlutterStandardTypedData(bytes: data)) }
    }
  }

  private func setVoiceProcessing(echoCancel: Bool, autoGain: Bool, audioEngine: AVAudioEngine) throws {
    do {
      try audioEngine.inputNode.setVoiceProcessingEnabled(echoCancel)
      audioEngine.inputNode.isVoiceProcessingAGCEnabled = autoGain
    } catch {
      throw RecorderError.error(
        message: "Failed to setup voice processing",
        details: "Echo cancel error: \(error)"
      )
    }
  }
}
