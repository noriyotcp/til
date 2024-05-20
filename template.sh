#!/bin/bash
# This is for macOS

MSG=$(cat <<-EOD
DESCRIPTION
    The options are as follows:
    [+|-]val    Adjust the day according to val
    -t          Create a file as tommorow
    -h          Display this help
EOD
)

if [ ${#} -eq 0 ]; then
  DATE=$(date +"%Y-%m-%d")
elif [[ "${1}" =~ ^((\+|\-)[[:digit:]]+)$ ]]; then
  DATE=$(date -v "${BASH_REMATCH[1]}"d +"%Y-%m-%d")
elif [ "${1}" = "-t" ]; then
  DATE=$(date -v +1d +"%Y-%m-%d")
elif [ "${1}" = "-h" ]; then
  echo "$MSG"
  exit 0
else
  echo "Invalid option"
  echo "$MSG"
  exit 1
fi

cat <<-EOD >> ./"${DATE}".md
# ${DATE}

EOD

