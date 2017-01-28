#!/bin/sh

set -e  # Fail (and stop build) on first non zero exit code
( set -o pipefail; set -x; xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Debug -destination "$TEST_DEST" -sdk "$TEST_SDK" -enableCodeCoverage YES build-for-testing | bundler exec xcpretty )
( set -o pipefail; set -x; xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Debug -destination "$TEST_DEST" -sdk "$TEST_SDK" -enableCodeCoverage YES test              | bundler exec xcpretty )
set +e
