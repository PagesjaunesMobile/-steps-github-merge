#!/bin/bash

set -v

THIS_SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start go program
cd "${THIS_SCRIPTDIR}"

set -e
set
ruby ./step.rb