#!/bin/bash
#$ -cwd

#$ -l cpu_4=1
#$ -l h_rt=0:30:00
#$ -j y
#$ -cwd

REPO_PATH=$1

####

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
deactivate

cd $REPO_PATH
