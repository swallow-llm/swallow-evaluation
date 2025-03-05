#!/bin/bash
source .venv_bigcode/bin/activate

# This script is used to evaluate
# humaneval (unstripped)
# to evaluate with all testcases, set NUM_TESTCASE=None

MODEL_NAME_PATH=$1
DO_GENERATION=$2
DO_EVAL=$3
CUDA_BLOCKING=${4:-}

NUM_SAMPLES=10
BATCH_SIZE=10
OUTDIR="results/${MODEL_NAME_PATH}/en/humaneval-unstripped"

# Set CUDA_LAUNCH_BLOCKING to prevent evaluation from stopping at a certain batch
# (This setting should be done only if necessary because it might slow evaluation)
if [ -n "$CUDA_BLOCKING" ]; then
  export CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING
else
  unset CUDA_LAUNCH_BLOCKING
fi
echo CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast_tokenizer=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=''
else
    USE_FAST_TOKENIZER='--use_fast_tokenizer'
fi

mkdir -p $OUTDIR

if [ ${DO_GENERATION} = "true" ]; then
  echo "Generating"
  start_time=$(date +%s)
  python bigcode-evaluation-harness/main.py \
    --model ${MODEL_NAME_PATH} \
    --tasks humaneval-unstripped \
    --do_sample True \
    --n_samples ${NUM_SAMPLES} \
    --batch_size ${BATCH_SIZE} \
    --save_generations \
    --generation_only \
    --save_generations_path ${OUTDIR}/generation.json \
    --use_auth_token \
    --max_memory_per_gpu auto \
    --trust_remote_code \
    --max_length_generation 1024 \
    ${USE_FAST_TOKENIZER}
  end_time=$(date +%s)
  execution_time=$((end_time - start_time))
  echo "Generation time: ${execution_time} seconds"
fi

if [ ${DO_EVAL} = "true" ]; then
  echo "Evaluating"
  echo "Generated codes should be placed at ${OUTDIR}/generation_humaneval-unstripped.json ."
  touch ${OUTDIR}/metrics.json
  
  start_time=$(date +%s)
  docker run \
    -v $(pwd)/${OUTDIR}/generation_humaneval.json:/app/generations_py.json \
    -v $(pwd)/${OUTDIR}/metrics.json:/app/metrics.json \
    -it evaluation-harness python3 main.py \
    --model ${MODEL_NAME_PATH} \
    --tasks humaneval \
    --load_generations_path /app/generations_py.json \
    --allow_code_execution \
    --n_samples 10 \
    --metric_output_path /app/metrics.json

  python bigcode-evaluation-harness/bigcode_eval/custom_utils.py \
    --generation_path $(pwd)/${OUTDIR}/generation_humaneval.json \
    --metrics_path $(pwd)/${OUTDIR}/metrics.json \
    --task humaneval

  end_time=$(date +%s)
  execution_time=$((end_time - start_time))
  echo "Evaluating time: ${execution_time} seconds"
fi

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH