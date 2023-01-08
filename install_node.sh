#!/usr/bin/env bash

set -euo pipefail
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.bashrc
nvm install 14.15.1 && nvm use 14.15.1