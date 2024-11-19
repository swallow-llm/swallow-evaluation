#!/bin/bash
#$ -cwd

#$ -l cpu_4=1
#$ -l h_rt=0:30:00
#$ -j y
#$ -cwd

REPO_PATH="/gs/fs/tga-okazaki/saito/jalm-evaluation-private"

####

cd $REPO_PATH

module load cuda/12.1.0
module load cudnn/9.0.0

python -m venv .venv_bigcode

source .venv_bigcode/bin/activate
cd bigcode-evaluation-harness
pip install --upgrade pip
pip install -e .
pip install sentencepiece==0.2.0 protobuf==5.28.3 transformers==4.46.2
pip install 'accelerate>=0.26.0'
pip install datasets==2.21.0
pip install vllm==v0.6.3.post1
deactivate

cd $REPO_PATH

apptainer pull docker://ghcr.io/bigcode-project/evaluation-harness