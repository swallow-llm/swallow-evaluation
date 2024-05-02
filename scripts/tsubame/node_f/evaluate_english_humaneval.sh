#!/bin/bash
#$ -cwd

#$ -l node_f=1
#$ -l h_rt=24:00:00

# module load
. /etc/profile.d/modules.sh
module load cuda/12.1.0
module load cudnn/9.0.0

REPO_PATH=$1
HUGGINGFACE_CACHE=$2
MODEL_ID=$3

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

cd $REPO_PATH

source .venv_bigcode/bin/activate

NUM_SAMPLES=10
BATCH_SIZE=10
OUTDIR="${REPO_PATH}/results/${MODEL_ID}/en/humaneval"

mkdir -p $OUTDIR

#accelerate launch bigcode-evaluation-harness/main.py \
python bigcode-evaluation-harness/main.py \
  --model ${MODEL_ID} \
  --tasks humaneval \
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

# aggregate results
python scripts/aggregate_result.py --model $MODEL_ID