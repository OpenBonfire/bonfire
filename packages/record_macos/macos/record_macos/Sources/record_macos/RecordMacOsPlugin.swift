import AVFoundation
import FlutterMacOS
import Cocoa

public class RecordMacOsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let binaryMessenger = registrar.messenger
    let methodChannel = FlutterMethodChannel(name: "com.llfbandit.record/messages", binaryMessenger: binaryMessenger)
    let instance = RecordMacOsPlugin(binaryMessenger: binaryMessenger)
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
  }

  private var m_binaryMessenger: FlutterBinaryMessenger
  private let m_recorderQueue = DispatchQueue(label: "com.record.pluginQueue", qos: .userInitiated)
  private var m_recorders = [String: Recorder]()

  init(binaryMessenger: FlutterBinaryMessenger) {
    self.m_binaryMessenger = binaryMessenger
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    dispose()
  }

  func dispose() {
    m_recorderQueue.async {
      for (_, recorder) in self.m_recorders { recorder.dispose() }
      self.m_recorders = [:]
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "record", message: "Failed to parse call.arguments from Flutter.", details: nil))
      return
    }
    guard let recorderId = args["recorderId"] as? String else {
      result(FlutterError(code: "record", message: "Call missing mandatory parameter recorderId.", details: nil))
      return
    }

    if call.method == "hasPermission" {
      handleHasPermission(args: args, result: result)
      return
    }

    if call.method == "create" {
      handleCreate(recorderId: recorderId, result: result)
      return
    }

    withRecorder(recorderId: recorderId, result: result) { recorder in
      switch call.method {
      case "start":        self.handleStart(recorder: recorder, args: args, result: result)
      case "startStream":  self.handleStartStream(recorder: recorder, args: args, result: result)
      case "stop":         self.handleStop(recorder: recorder, result: result)
      case "cancel":       self.handleCancel(recorder: recorder, result: result)
      case "pause":        self.handlePause(recorder: recorder, result: result)
      case "resume":       self.handleResume(recorder: recorder, result: result)
      case "isPaused":     self.run(result: result) { recorder.isPaused() }
      case "isRecording":  self.run(result: result) { recorder.isRecording() }
      case "getAmplitude": self.run(result: result) { recorder.getAmplitude() }
      case "isEncoderSupported": self.handleIsEncoderSupported(recorder: recorder, args: args, result: result)
      case "listInputDevices":   self.handleListInputDevices(recorder: recorder, result: result)
      case "dispose":            self.handleDispose(recorderId: recorderId, recorder: recorder, result: result)
      default: DispatchQueue.main.async { result(FlutterMethodNotImplemented) }
      }
    }
  }

  // MARK: - Handlers (all run on m_recorderQueue via withRecorder)

  private func handleCreate(recorderId: String, result: @escaping FlutterResult) {
    let stateEventChannel = FlutterEventChannel(name: "com.llfbandit.record/events/\(recorderId)", binaryMessenger: m_binaryMessenger)
    let stateEventHandler = StateStreamHandler()
    stateEventChannel.setStreamHandler(stateEventHandler)

    let recordEventChannel = FlutterEventChannel(name: "com.llfbandit.record/eventsRecord/\(recorderId)", binaryMessenger: m_binaryMessenger)
    let recordEventHandler = RecordStreamHandler()
    recordEventChannel.setStreamHandler(recordEventHandler)

    let configChangedChannel = FlutterMethodChannel(name: "com.llfbandit.record/configChanged/\(recorderId)", binaryMessenger: m_binaryMessenger)
    let recorder = Recorder(queue: m_recorderQueue, stateEventHandler: stateEventHandler, recordEventHandler: recordEventHandler, configChangedChannel: configChangedChannel)

    m_recorderQueue.async {
      self.m_recorders[recorderId]?.dispose()
      self.m_recorders[recorderId] = recorder
      DispatchQueue.main.async { result(nil) }
    }
  }

  private func handleStart(recorder: Recorder, args: [String: Any], result: @escaping FlutterResult) {
    guard let path = args["path"] as? String else {
      DispatchQueue.main.async { result(FlutterError(code: "record", message: "Call missing mandatory parameter path.", details: nil)) }
      return
    }
    run(result: result) { try recorder.start(config: try RecordConfig.fromMap(args), path: path) }
  }

  private func handleStartStream(recorder: Recorder, args: [String: Any], result: @escaping FlutterResult) {
    run(result: result) { try recorder.startStream(config: try RecordConfig.fromMap(args)) }
  }

  private func handleStop(recorder: Recorder, result: @escaping FlutterResult) {
    let path = recorder.stop()
    DispatchQueue.main.async { result(path) }
  }

  private func handleCancel(recorder: Recorder, result: @escaping FlutterResult) {
    run(result: result) { try recorder.cancel() }
  }

  private func handlePause(recorder: Recorder, result: @escaping FlutterResult) {
    recorder.pause()
    DispatchQueue.main.async { result(nil) }
  }

  private func handleResume(recorder: Recorder, result: @escaping FlutterResult) {
    run(result: result) { try recorder.resume() }
  }

  private func handleHasPermission(args: [String: Any], result: @escaping FlutterResult) {
    let request = args["request"] as? Bool ?? true
    switch AVCaptureDevice.authorizationStatus(for: .audio) {
    case .authorized:
      result(true)
    case .notDetermined:
      if request {
        AVCaptureDevice.requestAccess(for: .audio) { allowed in
          DispatchQueue.main.async { result(allowed) }
        }
      } else {
        result(false)
      }
    default:
      result(false)
    }
  }

  private func handleIsEncoderSupported(recorder: Recorder, args: [String: Any], result: @escaping FlutterResult) {
    guard let encoder = args["encoder"] as? String else {
      DispatchQueue.main.async { result(FlutterError(code: "record", message: "Call missing mandatory parameter encoder.", details: nil)) }
      return
    }
    run(result: result) { recorder.isEncoderSupported(encoder) }
  }

  private func handleListInputDevices(recorder: Recorder, result: @escaping FlutterResult) {
    run(result: result) { try recorder.listInputDevices().map { $0.toMap() } }
  }

  private func handleDispose(recorderId: String, recorder: Recorder, result: @escaping FlutterResult) {
    m_recorders.removeValue(forKey: recorderId)
    recorder.dispose()
    DispatchQueue.main.async { result(nil) }
  }

  // MARK: - Helpers

  /// Dispatches the recorder lookup to m_recorderQueue, then runs block on that same queue.
  /// All results are dispatched back to the main thread.
  private func withRecorder(
    recorderId: String,
    result: @escaping FlutterResult,
    _ block: @escaping (Recorder) -> ()
  ) {
    m_recorderQueue.async {
      guard let recorder = self.m_recorders[recorderId] else {
        DispatchQueue.main.async {
          result(FlutterError(code: "record", message: "Recorder has not yet been created or has already been disposed.", details: nil))
        }
        return
      }
      block(recorder)
    }
  }

  /// Runs a throwing block on the current queue and dispatches the result (or error) to main.
  /// Must be called from m_recorderQueue (i.e. inside withRecorder).
  private func run<T>(result: @escaping FlutterResult, _ block: () throws -> T) {
    do {
      let value = try block()
      DispatchQueue.main.async {
        if T.self == Void.self { result(nil) } else { result(value) }
      }
    } catch let RecorderError.error(message, details) {
      DispatchQueue.main.async { result(FlutterError(code: "record", message: message, details: details)) }
    } catch {
      DispatchQueue.main.async { result(FlutterError(code: "record", message: error.localizedDescription, details: nil)) }
    }
  }
}
