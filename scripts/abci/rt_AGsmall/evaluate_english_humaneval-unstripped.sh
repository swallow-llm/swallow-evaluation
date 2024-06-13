#!/bin/bash

#$ -l rt_AG.small=1
#$ -l h_rt=24:00:00
#$ -j y
#$ -cwd

source ~/.bashrc
source /etc/profile.d/modules.sh
conda deactivate
module load python/3.10/3.10.14
module load cuda/12.1/12.1.1
module load cudnn/9.0/9.0.0

REPO_PATH=$1
HUGGINGFACE_CACHE=$2
MODEL_NAME_PATH=$3
LOCAL_PATH=$4

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

cd $REPO_PATH

source .venv_bigcode/bin/activate

NUM_SAMPLES=10
BATCH_SIZE=1
OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/en/humaneval-unstripped"

mkdir -p $OUTDIR

# generate

python bigcode-evaluation-harness/main.py \
  --model ${MODEL_NAME_PATH} \
  --tasks humaneval-unstripped \
  --do_sample True \
  --n_samples ${NUM_SAMPLES} \
  --batch_size ${BATCH_SIZE} \
  --allow_code_execution \
  --save_generations \
  --generation_only \
  --save_generations_path ${OUTDIR}/generation.json \
  --use_auth_token \
  --max_memory_per_gpu auto \
  --trust_remote_code \
  --max_length_generation 1024

# evaluate

ssh hestia "mkdir -p ${LOCAL_PATH}"
scp ${OUTDIR}/generation_humaneval-unstripped.json hestia:${LOCAL_PATH}
ssh hestia "curl -X POST -F \"model_name=${MODEL_NAME_PATH}\" -F \"file=@${LOCAL_PATH}/generation_humaneval-unstripped.json\" http://localhost:5000/api" > ${OUTDIR}/metrics.json
python bigcode-evaluation-harness/bigcode_eval/custom_utils.py --generation_path ${OUTDIR}/generation_humaneval-unstripped.json --metrics_path ${OUTDIR}/metrics.json

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH