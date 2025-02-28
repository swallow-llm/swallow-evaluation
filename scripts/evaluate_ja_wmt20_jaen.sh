#!/bin/bash
source .venv_harness_jp/bin/activate

# This script is used to evaluate
# wmt20-ja-en
# to evaluate with all testcases, set NUM_TESTCASE=None

MODEL_NAME_PATH=$1
CUDA_BLOCKING=${2:-}

NUM_FEWSHOT=4
NUM_TESTCASE="all"
OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/wmt20_ja_en/wmt20_ja_en_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

# Set CUDA_LAUNCH_BLOCKING to prevent evaluation from stopping at a certain batch
# (This setting should be done only if necessary because it might slow evaluation)
if [ -n "$CUDA_BLOCKING" ]; then
  export CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING
else
  unset CUDA_LAUNCH_BLOCKING
fi
echo CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=False
else
    USE_FAST_TOKENIZER=True
fi

# MODEL_NAME_PATHにgemma-2が含まれているとき,add_special_tokens=Trueが指定される
if [[ $MODEL_NAME_PATH == *"gemma-2"* ]]; then
    ADD_SPECIAL_TOKENS=True
else
    ADD_SPECIAL_TOKENS=False
fi

mkdir -p ${OUTDIR}

start_time=$(date +%s)
python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args "pretrained=$MODEL_NAME_PATH,use_accelerate=True,trust_remote_code=True,use_fast=$USE_FAST_TOKENIZER,add_special_tokens=$ADD_SPECIAL_TOKENS" \
    --tasks "wmt20-ja-en" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 2 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_wmt20_ja_en.json \
    --use_cache ${OUTDIR}
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Evaluation time: ${execution_time} seconds"

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH