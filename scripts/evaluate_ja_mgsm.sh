#!/bin/bash

# running lm-evaluation-harness-jp for mgsm task
source .venv_harness_jp/bin/activate
export TOKENIZERS_PARALLELISM=false

MODEL_NAME_PATH=$1
NUM_FEWSHOT=$2
NUM_TESTCASE="all"

OUTDIR="results/${MODEL_NAME_PATH}/ja/math_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args pretrained=$MODEL_NAME_PATH \
    --tasks "mgsm" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 2 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_math.json
