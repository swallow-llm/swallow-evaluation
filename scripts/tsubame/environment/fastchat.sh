#!/bin/bash

#$ -l cpu_4=1
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

python -m venv .venv_fastchat

source .venv_fastchat/bin/activate
cd fastchat
pip install --upgrade pip
pip install python-dotenv pandas
pip install -e ".[model_worker,llm_judge]"
pip install vllm==v0.6.3.post1
deactivate

cd $REPO_PATH
echo Make sure to write your OPENAI API KEY in .env to generate judgements with OpenAI API.