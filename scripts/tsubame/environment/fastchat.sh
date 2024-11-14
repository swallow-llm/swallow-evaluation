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
pip install torch==2.1.0 --index-url https://download.pytorch.org/whl/cu121
pip install python-dotenv pandas "pydantic<2,>=1.10.9"
pip install -e ".[model_worker,llm_judge]"
pip install transformers 'accelerate>=0.26.0' vllm
deactivate

cd $REPO_PATH