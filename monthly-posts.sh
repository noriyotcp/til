#!/bin/sh

MSG="${BASH_SOURCE:-$0} $(date +"%Y-%m")"

if [ ${#} -eq 0 ]; then
  echo "No args: eg) ${MSG}"
elif [ "${1}" = "-h" ]; then
  echo "${MSG}"
else
  mkdir "${1}"
  mv "${1}"*.md "${1}"
fi

