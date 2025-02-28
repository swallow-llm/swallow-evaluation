#!/bin/bash
source .venv_harness_en/bin/activate

# This script is used to evaluate
# math
# to evaluate with all testcases, set NUM_TESTCASE=None

MODEL_NAME_PATH=$1
CUDA_BLOCKING=${2:-}

MATH_NUM_FEWSHOT=4
MATH_NUM_TESTCASE="all"
MATH_BATCH_SIZE=8
OUTDIR="results/${MODEL_NAME_PATH}/en/harness_en"

# Set CUDA_LAUNCH_BLOCKING to prevent evaluation from stopping at a certain batch
# (This setting should be done only if necessary because it might slow evaluation)
if [ -n "$CUDA_BLOCKING" ]; then
  export CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING
else
  unset CUDA_LAUNCH_BLOCKING
fi
echo CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING

MATH_TASK_NAME="math_500"
MATH_OUTDIR="${OUTDIR}/alltasks_${MATH_NUM_FEWSHOT}shot_${MATH_NUM_TESTCASE}cases/${MATH_TASK_NAME}"

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast_tokenizer=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=False
else
    USE_FAST_TOKENIZER=True
fi

mkdir -p $MATH_OUTDIR

cd lm-evaluation-harness-en

echo "Generating: ${MATH_TASK_NAME}"
start_time=$(date +%s)
lm_eval --model hf \
    --model_args "pretrained=$MODEL_NAME_PATH,parallelize=True,trust_remote_code=True,use_fast_tokenizer=$USE_FAST_TOKENIZER" \
    --tasks $MATH_TASK_NAME \
    --num_fewshot $MATH_NUM_FEWSHOT \
    --batch_size $MATH_BATCH_SIZE \
    --device cuda \
    --write_out \
    --output_path "$MATH_OUTDIR" \
    --use_cache "$MATH_OUTDIR" \
    --log_samples \
    --seed 42
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Generation time: ${execution_time} seconds"

# aggregate results
cd ../
python scripts/aggregate_result.py --model $MODEL_NAME_PATH
