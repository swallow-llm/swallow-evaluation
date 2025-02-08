#!/bin/bash
set -e

REPO_PATH=$1
PIP_CACHEDIR=$2
SINGULARITY_CACHEDIR=$3

####

cd $REPO_PATH

source ~/.bashrc
source /etc/profile.d/modules.sh

# module load python/3.10/3.10.14
module load cuda/12.1/12.1.1
# module load cudnn/9.0/9.0.0
module load cudnn/9.5/9.5.1 

python3 -m venv .venv_bigcode

source .venv_bigcode/bin/activate
cd bigcode-evaluation-harness/
pip install --upgrade pip --cache-dir ${PIP_CACHEDIR}
pip install -e . --cache-dir ${PIP_CACHEDIR}
pip install sentencepiece==0.2.0 protobuf==5.28.3 transformers==4.46.2 --cache-dir ${PIP_CACHEDIR}
pip install 'accelerate>=0.26.0' --cache-dir ${PIP_CACHEDIR}
pip install datasets==2.21.0 --cache-dir ${PIP_CACHEDIR}
pip install vllm==v0.6.3.post1 --cache-dir ${PIP_CACHEDIR}
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121 --cache-dir ${PIP_CACHEDIR}
deactivate

cd $REPO_PATH

# singularity set-up　(takes at most 30 minutes)
export SINGULARITY_CACHEDIR=$SINGULARITY_CACHEDIR
singularity pull docker://ghcr.io/bigcode-project/evaluation-harness
singularity shell evaluation-harness_latest.sif
pip install --user datasets==2.21.0