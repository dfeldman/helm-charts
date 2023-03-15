#!/usr/bin/env bash

test_directory="${1}"
namespace="$(basename "${test_directory}")"

export EXTRA_HELM_ARGS=""

[ "${namespace}" != "default" ] && kubectl create namespace "${namespace}"

post-install() {
  local exitCode=$?
  [ -x "${test_directory}/post-install.sh" ] && "${test_directory}/post-install.sh" $exitCode
  exit $exitCode
}

trap 'post-install $? $LINENO' EXIT

[ -x "${test_directory}/pre-install.sh" ] && "${test_directory}/pre-install.sh"
# shellcheck source=/dev/null
[ -f "${test_directory}/.env" ] && source "${test_directory}/.env"
if [ -x "${TEST_DIR}/install.sh" ]; then
  "${test_directory}/install.sh"
else
  ct install --debug \
    --namespace "${namespace}" \
    --target-branch "${GITHUB_BASE_REF}" \
    --exclude-deprecated \
    ${{ (matrix.values != 'default' && '--helm-extra-set-args "--values=${test_directory}/values.yaml ${EXTRA_HELM_ARGS}"') || '' }}
fi
