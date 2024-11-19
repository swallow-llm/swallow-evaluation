#!/bin/bash

#$ -l cpu_4=1
#$ -l h_rt=0:30:00
#$ -j y
#$ -cwd

REPO_PATH="/gs/fs/tga-okazaki/saito/jalm-evaluation-private"

####

cd $REPO_PATH

module load cuda/12.1.0
module load cudnn/9.0.0

python -m venv .venv_fastchat

source .venv_fastchat/bin/activate
cd fastchat
pip install --upgrade pip
pip install python-dotenv pandas
pip install -e ".[model_worker,llm_judge]"
pip install vllm
pip install torch --index-url https://download.pytorch.org/whl/cu121
deactivate

cd $REPO_PATH