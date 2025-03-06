#!/bin/bash
source .venv_fastchat/bin/activate

# This script is used to evaluate
# mt-bench
# to evaluate with all testcases, set NUM_TESTCASE=None

MODEL_NAME_PATH=$1
GPU_NUM=$2
CUDA_BLOCKING=${3:-}

OUTDIR="results/${MODEL_NAME_PATH}/ja/ja_mt_bench"

# Set CUDA_LAUNCH_BLOCKING to prevent evaluation from stopping at a certain batch
# (This setting should be done only if necessary because it might slow evaluation)
if [ -n "$CUDA_BLOCKING" ]; then
  export CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING
else
  unset CUDA_LAUNCH_BLOCKING
fi
echo CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING

mkdir -p ${OUTDIR}
cd fastchat/fastchat/llm_judge

echo "Generating model answers"
start_time=$(date +%s)
python gen_model_answer.py \
  --model-path ${MODEL_NAME_PATH} \
  --model-id ${MODEL_NAME_PATH} \
  --bench-name japanese_mt_bench \
  --num-choices 5 \
  --num-gpus-total $GPU_NUM \
  --num-gpus-per-model $GPU_NUM
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Generation model answers time: ${execution_time} seconds"

echo "Generating judgements"
start_time=$(date +%s)
python gen_judgment.py \
  --model-list ${MODEL_NAME_PATH} \
  --bench-name japanese_mt_bench \
  --parallel 4 \
  --judge-model gpt-4o-2024-08-06
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Generation judgements time: ${execution_time} seconds"

python show_result.py \
  --model-list ${MODEL_NAME_PATH} \
  --bench-name japanese_mt_bench \
  --output-file ../../../${OUTDIR}/judge.json \
  --judge-model gpt-4o-2024-08-06

# aggregate results
cd ../../../
python scripts/aggregate_result.py --model $MODEL_NAME_PATH