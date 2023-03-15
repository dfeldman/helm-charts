#!/usr/bin/env bash

set -x

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

ct install --debug \
  --namespace spire-server \
  --target-branch "${GITHUB_BASE_REF}" \
  --helm-extra-set-args "--values=${SCRIPTPATH}/../../../examples/production/values.yaml" \
  spire charts/spire
