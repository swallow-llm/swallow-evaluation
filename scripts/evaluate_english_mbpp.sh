#!/bin/bash

source .venv_bigcode/bin/activate

MODEL_NAME_PATH=$1
CUDA_BLOCKING=${2:-}
NUM_SAMPLES=10
BATCH_SIZE=1

# Set CUDA_LAUNCH_BLOCKING to prevent evaluation from stopping at a certain batch
# (This setting should be done only if necessary because it might slow evaluation)
if [ -n "$CUDA_BLOCKING" ]; then
  export CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING
else
  unset CUDA_LAUNCH_BLOCKING
fi
echo CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING

OUTDIR="results/${MODEL_NAME_PATH}/en/mbpp"

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast_tokenizer=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=''
else
    USE_FAST_TOKENIZER='--use_fast_tokenizer'
fi

mkdir -p $OUTDIR

# generate

python bigcode-evaluation-harness/main.py \
  --model ${MODEL_NAME_PATH} \
  --tasks mbpp \
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
  --max_length_generation 2048 \
  --temperature 0.1 \
  ${USE_FAST_TOKENIZER}

# evaluate
curl -X POST -F "model_name=${MODEL_NAME_PATH}" -F "file=@${OUTDIR}/generation_mbpp.json" -F "task=mbpp" http://localhost:5001/api > ${OUTDIR}/metrics.json
python bigcode-evaluation-harness/bigcode_eval/custom_utils.py --generation_path ${OUTDIR}/generation_mbpp.json --metrics_path ${OUTDIR}/metrics.json --task mbpp

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH