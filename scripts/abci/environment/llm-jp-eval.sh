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

python3 -m venv .venv_llm_jp_eval

source .venv_llm_jp_eval/bin/activate

cd llm-jp-eval/
pip install --upgrade pip
pip install -e .
pip install sentencepiece
pip install protobuf
pip install transformers_stream_generator einops tiktoken

python scripts/preprocess_dataset.py --dataset-name all --output-dir dataset