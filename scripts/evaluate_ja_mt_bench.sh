#!/bin/bash

source .venv_fastchat/bin/activate
MODEL_NAME_PATH=$1
GPU_NUM=$2
CUDA_BLOCKING=${3:-}

# Set CUDA_LAUNCH_BLOCKING to prevent evaluation from stopping at a certain batch
# (This setting should be done only if necessary because it might slow evaluation)
if [ -n "$CUDA_BLOCKING" ]; then
  export CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING
else
  unset CUDA_LAUNCH_BLOCKING
fi
echo CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING

OUTDIR="results/${MODEL_NAME_PATH}/ja/ja_mt_bench"
mkdir -p $OUTDIR

cd fastchat/fastchat/llm_judge
python gen_model_answer.py --model-path ${MODEL_NAME_PATH} --model-id ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --num-choices 5 --num-gpus-total ${GPU_NUM} --num-gpus-per-model ${GPU_NUM}
python gen_judgment.py --model-list ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --parallel 2 --judge-model gpt-4-1106-preview
python show_result.py --model-list ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --output-file ../../../${OUTDIR}/judge.json --judge-model gpt-4-1106-preview
cd ../../../

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH