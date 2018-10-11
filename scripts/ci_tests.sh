#!/bin/bash

# Runs the test suite for the travis build
#
# If COVERALLS is true, then we report test coverage to coveralls.
#
# This script could be used for local testing as long as COVERALLS is not set.

set -e

export MIX_ENV=test

if [ "$CREDO" = true ]
then
  mix credo
fi

if [ "$COVERALLS" = true ]
then
  echo "Coveralls will be reported"
  TEST_COMMAND=coveralls.travis
else
  TEST_COMMAND=test
fi

mix "$TEST_COMMAND" --include integration --include consumer_group --include server_0_p_9_p_0 --include server_0_p_9_p_0 ||
  mix "$TEST_COMMAND" --include integration --include consumer_group --include server_0_p_9_p_0 --include server_0_p_9_p_0

