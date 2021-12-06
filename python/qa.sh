#!/bin/bash
#set -euxo pipefail

eval "$(conda shell.bash hook)"

conda activate gwells_locationqa
#which python
#python /GWELLS_LocationQA/gwells_locationqa.py geocode 21 geocoded.csv

cp   /GWELLS_LocationQA/gwells_locationqa.py  /tmp/workingdir/gwells_locationqa.py

python gwells_locationqa.py qa  









