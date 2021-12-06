#!/bin/bash
#set -euxo pipefail

eval "$(conda shell.bash hook)"
conda activate gwells_locationqa
#cp   /GWELLS_LocationQA/gwells_locationqa.py  ~/gwells_locationqa.py
python gwells_locationqa.py qa  









