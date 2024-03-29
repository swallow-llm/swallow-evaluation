#!/bin/bash

source .venv_bigcode/bin/activate


MODEL_NAME_PATH=$1
NUM_SAMPLES=10
BATCH_SIZE=10
OUTDIR="results/${MODEL_NAME_PATH}/ja/humaneval"

mkdir -p $OUTDIR

#accelerate launch bigcode-evaluation-harness/main.py \
python bigcode-evaluation-harness/main.py \
  --model ${MODEL_NAME_PATH} \
  --tasks jhumaneval \
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