#!/bin/bash

set -euo pipefail

# If `config-list-file` is unavailable, stop this job without continuation
if [[ ! -s "${CONFIG_LIST_ORIGINAL}" ]]; then
    echo 'Nothing to combine. Halting the job.'
    circleci-agent step halt
    exit
fi

CONFIG_LIST_MODIFIED=$(mktemp)
cat "${CONFIG_LIST_ORIGINAL}" >>"${CONFIG_LIST_MODIFIED}"

# If `shared-config-file` exists, append it at the end of `config-list-file`
if [[ -s "${SHARED_CONFIG_FILE}" ]]; then
    echo "${SHARED_CONFIG_FILE}" >>"${CONFIG_LIST_MODIFIED}"
fi

# shellcheck disable=SC2016
# NOTE: we use --yaml-roundtrip (-Y) instead of --yaml-output (-y) to preserve YAML tags and styles.
# We want to keep users' config YAML files as-is
xargs -a "${CONFIG_LIST_MODIFIED}" yq -Y -s 'reduce .[] as $item ({}; . * $item)' | tee "${OUTPUT}"
