#!/bin/bash

if ! command -v dot &> /dev/null; then

    sudo apt-get install graphviz
fi

python3 -m venv dag_venv
source dag_venv/bin/activate  
pip install graphviz
python generate_dag.py
deactivate