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

python3 -m venv .venv_fastchat

source .venv_fastchat/bin/activate
cd fastchat
pip install --upgrade pip --cache-dir ${PIP_CACHEDIR}
pip install python-dotenv pandas --cache-dir ${PIP_CACHEDIR}
pip install -e ".[model_worker,llm_judge]" --cache-dir ${PIP_CACHEDIR}
pip install vllm==v0.6.3.post1 --cache-dir ${PIP_CACHEDIR}
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121 --cache-dir ${PIP_CACHEDIR}
pip install markdown beautifulsoup4 --cache-dir ${PIP_CACHEDIR}
deactivate

cd $REPO_PATH
echo Make sure to write your OPENAI API KEY in .env to generate judgements with OpenAI API.