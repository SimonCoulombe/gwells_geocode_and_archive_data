#!/bin/bash
#set -euxo pipefail
eval "$(conda shell.bash hook)"
conda activate gwells_locationqa
python gwells_locationqa.py geocode  not_an_api_key
