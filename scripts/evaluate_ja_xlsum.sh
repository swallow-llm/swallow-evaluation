#!/bin/bash

# running lm-evaluation-harness-jp for xlsum task
source .venv_harness_jp/bin/activate
export TOKENIZERS_PARALLELISM=false

MODEL_NAME_PATH=$1
NUM_FEWSHOT=1
NUM_TESTCASE="all"

OUTDIR="results/${MODEL_NAME_PATH}/ja/xlsum/xlsum_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args pretrained=$MODEL_NAME_PATH \
    --tasks "xlsum_ja" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 2 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_xlsum.json
    --use_cache ${OUTDIR}

python scripts/aggregate_result.py --model $MODEL_NAME_PATH