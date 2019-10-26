#!/usr/bin/env bash

pkg=${1}

function help {
  echo "Usage: $(basename $0) <package name>"
  exit 1
}

[ -z ${pkg} ] && help

REXEC=$(which R)

if [ -z ${REXEC} ]; then
  echo "R not found, please ensure R is available and try again."
  exit 1
fi

echo "install.packages(\"${pkg}\", repos=\"https://cran.rstudio.com\")" | R --no-save
