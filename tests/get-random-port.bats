#!/usr/bin/env bats

load helpers/print/bprint

# shellcheck disable=SC1090
# https://github.com/koalaman/shellcheck/wiki/SC1090
# Bats ensure this directory
source "$BATS_TEST_DIRNAME/../bin/get-random-port"

readonly PORT=${TEST_PORT:-30000}

function setup() {
  # Ensure the two ports needed for the tests are available
  lsof -i -P -n | grep LISTEN | grep -vq ":${PORT}"
  lsof -i -P -n | grep LISTEN | grep -vq ":$((PORT+1))"
}

@test "it should use the start_from if nothing is running on the port" {
  RANDOM=0 run get-random-port $PORT

  [ $status -eq 0 ]
  [ "$output" = "$PORT" ]
}

@test "it should use the start_from+x if something is running on the port" {
  GREP="$(which grep)"
  function grep() {
    local grep_cmd=("$GREP" "${@:-}")
    if [ "$1" = ":$PORT" ]; then
      echo "processd    527 user    4u  IPv4 0xa894e6a0a7e08b      0t0  TCP *:$PORT (LISTEN)"
      return 0
    elif [[ "$1" =~ :.* ]]; then
      echo ""
      return 0
    fi

    "${grep_cmd[@]}"
  }

  RANDOM=0 run get-random-port $PORT

  [ $status -eq 0 ]
  [ "$output" = "$((PORT+1))" ]
}

@test "it should timeout after 10 attempts" {
  GREP="$(which grep)"
  function grep() {
    local grep_cmd=("$GREP" "${@:-}")
    if [[ "$1" =~ :.* ]]; then
      echo "processd    527 user    4u  IPv4 0xa894e6a0a7e08b      0t0  TCP *:$1 (LISTEN)"
      return 0
    fi

    "${grep_cmd[@]}"
  }

  RANDOM=0 run get-random-port $PORT

  [ $status -eq 1 ]
}
