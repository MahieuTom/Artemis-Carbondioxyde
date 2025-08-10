#!/usr/bin/env bash
# 1) Activate the IDF env (you already do this)
. ./scripts/prepare_sdk.sh

# 2) Select the correct chip so IDF knows to use the RISC-V toolchain
idf.py set-target esp32h2

# 3) Build
idf.py fullclean
idf.py reconfigure
idf.py build