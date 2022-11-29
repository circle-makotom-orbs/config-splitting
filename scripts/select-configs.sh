#!/bin/bash

set -euo pipefail

touch "${OUTPUT}"

DIFFS=$(
    cat <<EOD
$(git diff --name-only "${BASE_REVISION}")
$(git diff --name-only HEAD~1 || git ls-tree -r --name-only HEAD)
EOD
)
export DIFFS

while read -r module; do
    # Include if:
    #   1)  `force-all` is set to `true`,
    #   2)  there is any difference against `base-revision` or `HEAD~1` (the previous commit), or
    #   3)  there is no `HEAD~1` (i.e., this is the very first commit for the repo).
    if [[ "${FORCE_ALL}" == 'true' ]] || printenv DIFFS | grep -qs "^${module%%*(/)}"; then
        cat "${module}/${CONFIG_DEPENDENCIES_FILE}" >>"${OUTPUT}"
    fi
done <"${MODULE_LIST_FILE}"

sort -u -o "${OUTPUT}" "${OUTPUT}"
