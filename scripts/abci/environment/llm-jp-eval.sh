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

python3 -m venv .venv_llm_jp_eval

source .venv_llm_jp_eval/bin/activate
cd llm-jp-eval/
pip install --upgrade pip --cache-dir ${PIP_CACHEDIR}
pip install -e . --cache-dir ${PIP_CACHEDIR}
pip install protobuf sentencepiece --cache-dir ${PIP_CACHEDIR}
pip install 'accelerate>=0.26.0' --cache-dir ${PIP_CACHEDIR}
pip install datasets==2.21.0 --cache-dir ${PIP_CACHEDIR}
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121 --cache-dir ${PIP_CACHEDIR}
python scripts/preprocess_dataset.py --dataset-name all --output-dir ./dataset
deactivate