#!/bin/bash

source .venv_harness_en/bin/activate

# This script is used to evaluate
# triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squad2
# to evaluate with all testcases, set NUM_TESTCASE=None

MODEL_NAME_PATH=$1
TASK_NAME="triviaqa,hellaswag,squad2"
NUM_FEWSHOT=$2
NUM_TESTCASE="all"
OUTDIR="results/${MODEL_NAME_PATH}/en/group2_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

mkdir -p $OUTDIR

python lm-evaluation-harness-en/main.py \
    --model hf-causal-experimental \
    --model_args pretrained=$MODEL_NAME_PATH \
    --tasks $TASK_NAME \
    --num_fewshot $NUM_FEWSHOT \
    --max_batch_size 32 \
    --write_out \
    --device cuda \
    --output_base_path $OUTDIR \
    --output_path ${OUTDIR}/score.json
