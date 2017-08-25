#!/bin/bash
set -e

CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

"$CURRENT_PATH/ruby/update.rb"
