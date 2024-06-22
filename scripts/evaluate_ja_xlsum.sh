#!/bin/bash

# running lm-evaluation-harness-jp for xlsum task
source .venv_harness_jp/bin/activate
export TOKENIZERS_PARALLELISM=false

MODEL_NAME_PATH=$1
NUM_FEWSHOT=1
NUM_TESTCASE="all"

OUTDIR="results/${MODEL_NAME_PATH}/ja/xlsum/xlsum_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=False
else
    USE_FAST_TOKENIZER=True
fi

mkdir -p $OUTDIR

echo ${OUTDIR}
python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args "pretrained=$MODEL_NAME_PATH,use_accelerate=True,trust_remote_code=True,use_fast=$USE_FAST_TOKENIZER" \
    --tasks "xlsum_ja" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 2 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_xlsum.json \
    --use_cache ${OUTDIR}

python scripts/aggregate_result.py --model $MODEL_NAME_PATH