#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint capture_kit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'capture_kit'
  s.version          = '0.0.1'
  s.summary          = 'Camera/screen capture and hardware-accelerated H264 encoding.'
  s.description      = <<-DESC
Camera/screen capture and hardware-accelerated H264 encoding, in Rust.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.module_name      = 'capture_kit_core'

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  s.script_phase = {
    :name => 'Build Rust library',
    # First argument is relative path to the `rust` folder, second is name of rust library
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../rust capture_kit_core',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    # Let XCode know that the static library referenced in -force_load below is
    # created by this build step.
    :output_files => ["${PODS_CONFIGURATION_BUILD_DIR}/capture_kit_core/libcapture_kit_core.a"],
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    # Flutter.framework does not contain a i386 slice.
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    # -lc++/-lz: FFmpeg (rust/src/api/*.rs, via ffmpeg-the-third) and objc2 both
    # link C++/system libraries that `cargo build`'s own binary-link step would
    # normally pull in automatically - this crate only produces a staticlib for
    # cargokit/Xcode to link directly, so that final link step is Xcode's, not
    # cargo's, and needs telling separately (mirrors flutter_webrtc_rs's identical
    # openh264/-lc++ situation).
    'OTHER_LDFLAGS' => '-force_load ${PODS_CONFIGURATION_BUILD_DIR}/capture_kit_core/libcapture_kit_core.a -lc++ -lz -framework AVFoundation -framework CoreMedia -framework CoreVideo -framework VideoToolbox',
  }
end
