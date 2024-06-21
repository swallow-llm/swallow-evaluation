#!/bin/bash

#$ -l rt_AF=1
#$ -l h_rt=48:00:00
#$ -j y
#$ -cwd

repo_path=$1

source ~/.bashrc
source /etc/profile.d/modules.sh
conda deactivate
module load python/3.10/3.10.14
module load cuda/12.1/12.1.1
module load cudnn/9.0/9.0.0

REPO_PATH=$1
HUGGINGFACE_CACHE=$2
MODEL_NAME_PATH=$3

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

cd $REPO_PATH

source .venv_harness_jp/bin/activate

NUM_FEWSHOT=4
NUM_TESTCASE="all"
OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/wmt20_ja_en/wmt20_ja_en_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"
# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=False
else
    USE_FAST_TOKENIZER=True
fi

mkdir -p $OUTDIR

python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args "pretrained=$MODEL_NAME_PATH,use_accelerate=True,trust_remote_code=True,use_fast=$USE_FAST_TOKENIZER" \
    --tasks "wmt20-ja-en" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 2 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_wmt20_ja_en.json \
    --use_cache ${OUTDIR}

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH