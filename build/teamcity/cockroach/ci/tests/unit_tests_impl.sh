#!/usr/bin/env bash

set -xeuo pipefail

dir="$(dirname $(dirname $(dirname $(dirname $(dirname "${0}")))))"

source "$dir/teamcity-support.sh"  # for 'tc_release_branch'

bazel build //pkg/cmd/bazci --config=ci

EXTRA_PARAMS=""

if tc_release_branch; then
  # enable up to 2 retries (3 attempts, worst-case) per test executable to report flakes but only on release branches (i.e., not staging)
  EXTRA_PARAMS=" --flaky_test_attempts=3" 
fi

$(bazel info bazel-bin --config=ci)/pkg/cmd/bazci/bazci_/bazci -- test --config=cinolint --config=use_ci_timeouts -c fastbuild \
                                  //pkg:small_non_ccl_tests //pkg:medium_non_ccl_tests //pkg:large_non_ccl_tests //pkg:enormous_non_ccl_tests \
                                   --profile=/artifacts/profile.gz $EXTRA_PARAMS
