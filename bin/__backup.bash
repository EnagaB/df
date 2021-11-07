#!/usr/bin/env bash
set -u

# backup
# backup directory exist: $ cp (-r) file(dir) backup_dir/file.bak(dir.bak)
#              not exist: $ cp (-r) file(dir) .file.bak(.dir.bak)
# .bak -> .bak1 -> .bak2 -> ...

# parameters
declare -r backup_dirname='backup'

# backup
for fd in "$@"; do
  # split path
  fd1=$(dirname "$fd")
  fd2=$(basename "$fd")
  # ignore case
  [[ ! -e "$fd" ]] && continue
  [[ "$fd2" = "$backup_dirname" ]] && continue
  [[ "$fd2" = '.' ]] && continue
  [[ "$fd2" = '..' ]] && continue
  # check dir case
  if [[ -d ${fd1}/${backup_dirname} ]];then
    fd1=${fd1}/${backup_dirname}/
  else
    fd1=${fd1}/.
  fi
  # check exist
  fd3=${fd1}${fd2}.bak
  if [[ -e "$fd3" ]];then
    vn=1
    while :; do
      fd3=${fd1}${fd2}.bak${vn}
      if [[ ! -e "$fd3" ]];then
        break
      fi
      vn=$(($vn+1))
    done
  fi
  echo " backup: [${fd}] to [${fd3}]"
  if [[ -d "$fd" ]];then
    cp -r "${fd}" "${fd3}"
  else
    cp "${fd}" "${fd3}"
  fi
done

# end
