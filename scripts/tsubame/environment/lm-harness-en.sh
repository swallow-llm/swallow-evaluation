#!/bin/bash
#$ -cwd

#$ -l cpu_4=1
#$ -l h_rt=0:30:00

REPO_PATH="/gs/fs/tga-okazaki/saito/jalm-evaluation-private"

####

cd $REPO_PATH

module load cuda/12.1.0
module load cudnn/9.0.0

python -m venv .venv_harness_en

source .venv_harness_en/bin/activate
cd lm-evaluation-harness-en
pip install --upgrade pip
pip install -e .
pip install sentencepiece protobuf transformers
pip install 'accelerate>=0.26.0'
pip install vllm
deactivate

cd $REPO_PATH
