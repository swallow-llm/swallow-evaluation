#!/bin/bash
source .venv_harness_en/bin/activate

# This script is used to evaluate
# gpqa
# to evaluate with all testcases, set NUM_TESTCASE=None

MODEL_NAME_PATH=$1
CUDA_BLOCKING=${2:-}

GPQA_NUM_FEWSHOT=0
GPQA_NUM_TESTCASE="all"
GPQA_BATCH_SIZE=4
OUTDIR="results/${MODEL_NAME_PATH}/en/harness_en"

# Set CUDA_LAUNCH_BLOCKING to prevent evaluation from stopping at a certain batch
# (This setting should be done only if necessary because it might slow evaluation)
if [ -n "$CUDA_BLOCKING" ]; then
  export CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING
else
  unset CUDA_LAUNCH_BLOCKING
fi
echo CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING

GPQA_TASK_NAME="gpqa_main_cot_zeroshot_meta_llama3_wo_chat"
GPQA_OUTDIR="${OUTDIR}/alltasks_${GPQA_NUM_FEWSHOT}shot_${GPQA_NUM_TESTCASE}cases/gpqa_main_cot_zeroshot_meta_llama3_wo_chat"

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast_tokenizer=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=False
else
    USE_FAST_TOKENIZER=True
fi

mkdir -p $GPQA_OUTDIR

cd lm-evaluation-harness-en

echo "Generating: ${GPQA_TASK_NAME}"
start_time=$(date +%s)
lm_eval --model hf \
    --model_args "pretrained=$MODEL_NAME_PATH,parallelize=True,trust_remote_code=True,use_fast_tokenizer=$USE_FAST_TOKENIZER" \
    --tasks $GPQA_TASK_NAME \
    --num_fewshot $GPQA_NUM_FEWSHOT \
    --batch_size $GPQA_BATCH_SIZE \
    --device cuda \
    --write_out \
    --output_path "../$GPQA_OUTDIR" \
    --use_cache "../$GPQA_OUTDIR" \
    --log_samples \
    --seed 42
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Generation time: ${execution_time} seconds"

# aggregate results
cd ../
python scripts/aggregate_result.py --model $MODEL_NAME_PATH
