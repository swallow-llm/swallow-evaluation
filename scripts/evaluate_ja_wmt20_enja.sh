#!/bin/bash

# running lm-evaluation-harness-jp for wmt20 task
source .venv_harness_jp/bin/activate
export TOKENIZERS_PARALLELISM=false

MODEL_NAME_PATH=$1
NUM_FEWSHOT=4
NUM_TESTCASE="all"

OUTDIR="results/${MODEL_NAME_PATH}/ja/wmt20_en_ja/wmt20_en_ja_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"
mkdir -p $OUTDIR

python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args "pretrained=$MODEL_NAME_PATH,use_accelerate=True" \
    --tasks "wmt20-en-ja" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 2 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_wmt20_en_ja.json \
    --use_cache ${OUTDIR}

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH