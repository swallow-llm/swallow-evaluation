#!/bin/bash
set -e

REPO_PATH=$1
PIP_CACHEDIR=$2

####

cd $REPO_PATH

source ~/.bashrc
source /etc/profile.d/modules.sh

module load cuda/12.1/12.1.1
module load cudnn/9.5/9.5.1 

python3 -m venv .venv_harness_en

source .venv_harness_en/bin/activate

cd lm-evaluation-harness-en/
pip install --upgrade pip
pip install -e .
pip install sentencepiece
pip install protobuf
pip install transformers_stream_generator einops tiktoken
pip install antlr4-python3-runtime