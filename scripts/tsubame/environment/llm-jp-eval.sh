#!/bin/bash
#$ -cwd

#$ -l cpu_16=1
#$ -l h_rt=0:30:00
#$ -j y
#$ -cwd

set -e

REPO_PATH=$1
PIP_CACHE=$2

####

export PIP_CACHE_DIR=$PIP_CACHE

cd $REPO_PATH

module load cuda/12.1.0
module load cudnn/9.0.0

python -m venv .venv_llm_jp_eval

source .venv_llm_jp_eval/bin/activate
cd llm-jp-eval
pip install --upgrade pip
pip install -e .
pip install protobuf sentencepiece
pip install 'accelerate>=0.26.0'
pip install datasets==2.21.0
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121
python scripts/preprocess_dataset.py --dataset-name all --output-dir ./dataset
deactivate

cd $REPO_PATH
