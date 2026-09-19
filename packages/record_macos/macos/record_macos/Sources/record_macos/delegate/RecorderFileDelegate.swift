import AVFoundation
import Foundation

class RecorderFileDelegate: NSObject, AudioRecordingFileDelegate, AVCaptureFileOutputRecordingDelegate {
  var config: RecordConfig?

  private var m_audioSession: AVCaptureSession?
  private var m_audioOutput: AVCaptureAudioFileOutput?
  private var m_path: String?
  private var m_stoppingIntentionally = false
  private let m_queue: DispatchQueue
  private var m_onRecord: () -> ()
  private var m_onPause: () -> ()
  private var m_onStop: () -> ()

  init(queue: DispatchQueue, onRecord: @escaping () -> (), onPause: @escaping () -> (), onStop: @escaping () -> ()) {
    m_queue = queue
    m_onRecord = onRecord
    m_onPause = onPause
    m_onStop = onStop
  }

  func start(config: RecordConfig, path: String) throws {
    try deleteFile(path: path)

    let audioSession = AVCaptureSession()

    let dev: AVCaptureInput?
    do {
      dev = try getInputDevice(device: config.device)
    } catch {
      throw RecorderError.error(message: "Failed to start recording", details: "\(error)")
    }

    guard let dev = dev else {
      throw RecorderError.error(
        message: "Failed to start recording",
        details: "Input device not found from available list."
      )
    }
    guard audioSession.canAddInput(dev) else {
      throw RecorderError.error(
        message: "Failed to start recording",
        details: "Input device cannot be added to the capture session."
      )
    }

    audioSession.beginConfiguration()
    audioSession.addInput(dev)

    let audioOutput = AVCaptureAudioFileOutput()
    audioSession.addOutput(audioOutput)

    let outputSettings = try getOutputSettings(config: config)
    audioOutput.audioSettings = outputSettings

    audioSession.commitConfiguration()
    audioSession.startRunning()

    audioOutput.startRecording(
      to: URL(fileURLWithPath: path),
      outputFileType: getFileTypeFromSettings(outputSettings),
      recordingDelegate: self
    )

    m_audioOutput = audioOutput
    m_audioSession = audioSession
    m_path = path
    self.config = config

    m_onRecord()
  }

  func stop() -> String? {
    let path = teardown()
    m_onStop()
    return path
  }

  func pause() {
    guard let output = m_audioOutput else { return }
    output.pauseRecording()
    m_onPause()
  }

  func resume() throws {
    guard let output = m_audioOutput else { return }
    output.resumeRecording()
    m_onRecord()
  }

  func cancel() throws {
    guard let path = m_path else { return }
    _ = teardown()
    try deleteFile(path: path)
  }

  func getAmplitude() -> Float {
    return m_audioOutput?.connections.first?.audioChannels.first?.averagePowerLevel ?? -160
  }

  func dispose() {
    _ = stop()
  }

  public func fileOutput(
    _ output: AVCaptureFileOutput,
    didFinishRecordingTo outputFileURL: URL,
    from connections: [AVCaptureConnection],
    error: Error?
  ) {
    m_queue.async {
      if self.m_stoppingIntentionally {
        self.m_stoppingIntentionally = false
        return
      }
      // System-terminated recording (disk full, audio route loss, etc.) — clean up state.
      _ = self.stop()
    }
  }

  @discardableResult
  private func teardown() -> String? {
    m_stoppingIntentionally = true
    m_audioOutput?.stopRecording()
    m_audioOutput = nil
    m_audioSession?.stopRunning()
    m_audioSession = nil
    let path = m_path
    m_path = nil
    config = nil
    return path
  }

  private func deleteFile(path: String) throws {
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: path) else { return }
    do {
      try fileManager.removeItem(atPath: path)
    } catch {
      throw RecorderError.error(message: "Failed to delete previous recording", details: error.localizedDescription)
    }
  }
}
