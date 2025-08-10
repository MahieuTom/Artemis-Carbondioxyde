#!/usr/bin/env bash
set -euo pipefail

cur_path=${PWD}
if [[ "$OSTYPE" == "darwin"* ]]; then
    project_path=$(dirname $(dirname $(realpath $0)))
else 
    project_path=$(dirname $(dirname $(realpath $BASH_SOURCE)))
fi
# sdk_path=${project_path}/sdk
sdk_path=~/Developer/esp-sdk  # change to your own sdk path
esp_idf_path=${sdk_path}/esp-idf
esp_matter_path=${sdk_path}/esp-matter
chip_path=${esp_matter_path}/connectedhomeip/connectedhomeip
zap_path=${chip_path}/.environment/cipd/packages/zap

# Export for esp-matter scripts that require this env var
export ESP_MATTER_PATH="${esp_matter_path}"
# Other environment variables
export IDF_CCACHE_ENABLE=1
export CHIP_PATH="${chip_path}"

# Add ESP-IDF and ESP-Matter to terminal
source ${esp_idf_path}/export.sh
source ${esp_matter_path}/export.sh

# (optional) print git commit id of repositories
echo "------------------------------------------------------"
echo "[esp-idf]"
cd ${esp_idf_path}
git rev-parse HEAD
git show-branch
git describe --tags
echo "[esp-matter]"
cd ${esp_matter_path}
git rev-parse HEAD
git show-branch
git describe --tags
echo "[connectedhomeip]"
cd ${chip_path}
git rev-parse HEAD
git show-branch
git describe --tags
echo "[zap-cli]"
cd ${zap_path}
./zap-cli --version
echo "------------------------------------------------------"

cd ${cur_path}