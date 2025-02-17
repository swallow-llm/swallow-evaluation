#!/bin/bash
set -e

ROOT_PATH=$1
PIP_CACHEDIR=$2

####

cd $ROOT_PATH

source ~/.bashrc
source /etc/profile.d/modules.sh

module load cuda/12.1/12.1.1
module load cudnn/9.5/9.5.1 

python3 -m venv .venv_harness_en

source .venv_harness_en/bin/activate
cd lm-evaluation-harness-en/
pip install --upgrade pip --cache-dir ${PIP_CACHEDIR}
pip install -e  ".[math]" --cache-dir ${PIP_CACHEDIR}
pip install sentencepiece==0.2.0 protobuf==5.28.3 transformers==4.46.2 --cache-dir ${PIP_CACHEDIR}
pip install 'accelerate>=0.26.0' --cache-dir ${PIP_CACHEDIR}
pip install datasets==2.19.2 --cache-dir ${PIP_CACHEDIR}
pip install vllm==v0.6.3.post1 --cache-dir ${PIP_CACHEDIR}
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121 --cache-dir ${PIP_CACHEDIR}
deactivate