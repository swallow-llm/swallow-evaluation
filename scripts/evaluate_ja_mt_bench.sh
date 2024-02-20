#!/bin/bash

source .venv_fastchat/bin/activate

MODEL_NAME_PATH=$1

OUTDIR="results/${MODEL_NAME_PATH}/ja/ja_mt_bench"
mkdir -p ${OUTDIR}

cd fastchat/fastchat/llm_judge
#python gen_model_answer.py --model-path ${MODEL_NAME_PATH} --model-id ${MODEL_NAME_PATH} --bench-name japanese_mt_bench
#python gen_judgment.py --model-list ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --parallel 2
python show_result.py --model-list ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --output-file ../../../${OUTDIR}/judge.json
cd ../../../