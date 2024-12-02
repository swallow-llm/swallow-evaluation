#!/bin/bash
#$ -cwd

#$ -l cpu_16=1
#$ -l h_rt=0:30:00
#$ -j y
#$ -cwd

REPO_PATH=$1
PIP_CACHE=$2

####

export PIP_CACHE_DIR=$PIP_CACHE

cd $REPO_PATH

module load cuda/12.1.0
module load cudnn/9.0.0

python -m venv .venv_harness_jp

source .venv_harness_jp/bin/activate
cd lm-evaluation-harness-jp
pip install --upgrade pip
pip install -e ".[ja]"
pip install sacrebleu
pip install sentencepiece
pip install protobuf
pip install nagisa
pip uninstall -y torch torchvision torchaudio
pip install torch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 --index-url https://download.pytorch.org/whl/cu121
deactivate

cd $REPO_PATH
