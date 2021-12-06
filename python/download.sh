#!/bin/bash
#set -euxo pipefail

eval "$(conda shell.bash hook)"

conda activate gwells_locationqa
#which python
python /GWELLS_LocationQA/gwells_locationqa.py  download
