#!/usr/bin/env bash
set -u

# url
declare -r gurl='https://github.com'

### functions
function gclone_autoch() {
  local -r rrepo="$1" lrepo="$2"
  [[ -d "${lrepo}" ]] && return 1
  echo "[${rrepo}: git clone]"
  git clone --depth 1 "${gurl}/${rrepo}.git" "${lrepo}"
}

### enhancd
if $git_enhancd;then
  rrepo=b4b4r07/enhancd
  lrepo=${loc}/src/enhancd
  # download
  gclone_autoch "$rrepo" "$lrepo"
fi

# EOF
