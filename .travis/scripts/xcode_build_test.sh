#!/bin/sh

set -e  # Fail (and stop build) on first non zero exit code
( set -eox pipefail; xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Debug -destination "$TEST_DEST" -sdk "$TEST_SDK" -enableCodeCoverage YES build-for-testing | bundler exec xcpretty )
( set -eox pipefail; xcodebuild -workspace "$WORKSPACE" -scheme "$SCHEME" -configuration Debug -destination "$TEST_DEST" -sdk "$TEST_SDK" -enableCodeCoverage YES test              | bundler exec xcpretty )
set +e
