#!/bin/bash

source .venv_bigcode/bin/activate


MODEL_NAME_PATH=$1
DO_GENERATION=$2
DO_EVAL=$3
NUM_SAMPLES=10
BATCH_SIZE=10
OUTDIR="results/${MODEL_NAME_PATH}/en/humaneval"

mkdir -p $OUTDIR

if [ ${DO_GENERATION} = "true" ]; then
  echo "Generating"
  python bigcode-evaluation-harness/main.py \
    --model ${MODEL_NAME_PATH} \
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
fi

if [ ${DO_EVAL} = "true" ]; then
  echo "Evaluating"
  echo "Generated codes should be place at $(pwd)/${OUTDIR}/generation_humaneval.json ."
  touch $(pwd)/${OUTDIR}/metrics.json
  docker run -v $(pwd)/${OUTDIR}/generation_humaneval.json:/app/generations_py.json -v $(pwd)/${OUTDIR}/metrics.json:/app/metrics.json -it evaluation-harness python3 main.py --model ${MODEL_NAME_PATH} --tasks humaneval --load_generations_path /app/generations_py.json --allow_code_execution --n_samples 10 --metric_output_path /app/metrics.json
  python bigcode-evaluation-harness/bigcode_eval/custom_utils.py --generation_path $(pwd)/${OUTDIR}/generation_humaneval.json --metrics_path $(pwd)/${OUTDIR}/metrics.json
fi

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH