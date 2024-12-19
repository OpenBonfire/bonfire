#!/bin/sh

cd $(dirname "$0")
flutter test test_case_generator.dart

echo '------\nTest cases generated!'
