#!/usr/bin/env bash
#https://docs.espressif.com/projects/esp_matter/en/main/esp32/developing.html#development-setup
set -euo pipefail

cur_path=${PWD}
# Resolve project root (script dir -> parent)
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
else
  script_dir="$(cd "$(dirname "$0")" && pwd -P)"
fi
project_path="$(cd "${script_dir}/.." && pwd -P)"

# sdk_path=${project_path}/sdk
sdk_path=~/Developer/esp-sdk  # change to your own sdk path
if ! [ -d "${sdk_path}" ]; then
  mkdir ${sdk_path}
fi

esp_idf_path=${sdk_path}/esp-idf
esp_matter_path=${sdk_path}/esp-matter

# for Apple silicon
if [[ "$OSTYPE" == "darwin"* ]]; then
    export PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}:/opt/homebrew/opt/openssl@3/lib/pkgconfig"
    export IDF_CCACHE_ENABLE=1
else 
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install \
      git g++ gcc cmake ninja-build ccache pkg-config wget flex bison gperf dfu-util unzip \
      libssl-dev libffi-dev libusb-1.0-0 libglib2.0-dev libavahi-client-dev \
      libdbus-1-dev libgirepository1.0-dev libcairo2-dev libreadline-dev \
      python3 python3-dev python3-pip python3-venv python3-setuptools npm \
      -y
fi

# install esp-idf
cd ${sdk_path}
if [ ! -d "${esp_idf_path}" ]; then
    git clone --recursive https://github.com/espressif/esp-idf.git esp-idf
fi
cd ${esp_idf_path}
git fetch --all --tags
git checkout v5.4.1
git submodule update --init --recursive
bash ./install.sh esp32h2

# clone esp-matter repository and install connectedhomeip submodules      
cd ${sdk_path}
if [ ! -d "${esp_matter_path}" ]; then
    git clone --depth 1 https://github.com/espressif/esp-matter.git esp-matter
    git tag -a v1.0.0 -m "Initial release"
fi
cd ${esp_matter_path}
git submodule update --init --recursive
cd ./connectedhomeip/connectedhomeip
git fetch --tags
if [[ "$OSTYPE" == "darwin"* ]]; then
  ./scripts/checkout_submodules.py --platform esp32 darwin --shallow
else
  ./scripts/checkout_submodules.py --platform esp32 linux --shallow
fi

# Python environment setup
python3 -m venv ${sdk_path}/pip-venv
source ${sdk_path}/pip-venv/bin/activate

# install esp-matter and chip cores
cd ${esp_matter_path}
bash ./install.sh  # will call connectedhomeip "activate.sh"
source ${esp_matter_path}/export.sh

source ${esp_idf_path}/export.sh
pip install lark stringcase jinja2 pyqrcode pypng python-stdnum

# create symbolic link
cd ${project_path}
if ! [ -d "${project_path}/sdk" ]; then
  mkdir ${project_path}/sdk
fi
ln -s ${esp_idf_path} ${project_path}/sdk/esp-idf
ln -s ${esp_matter_path} ${project_path}/sdk/esp-matter

echo "ESP-IDF at ${esp_idf_path} (v5.4.1) and ESP-Matter at ${esp_matter_path} are set up."

cd ${cur_path}