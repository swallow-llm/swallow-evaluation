#!/bin/bash

#$ -l rt_AG.small=1
#$ -l h_rt=1:00:00
#$ -j y
#$ -cwd

repo_path=$1

source ~/.bashrc
source /etc/profile.d/modules.sh
conda deactivate
module load python/3.10/3.10.14
module load cuda/12.1/12.1.1
module load cudnn/9.0/9.0.0

cd $repo_path

python3 -m venv .venv_harness_en
source .venv_harness_en/bin/activate

cd lm-evaluation-harness-en/
pip install --upgrade pip
pip install -e .
pip install sentencepiece
pip install protobuf
pip install transformers_stream_generator einops tiktoken