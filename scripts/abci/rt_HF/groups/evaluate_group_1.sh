#!/bin/bash
set -e

source ~/.bashrc
source /etc/profile.d/modules.sh

module load cuda/12.1/12.1.1
module load cudnn/9.5/9.5.1 

REPO_PATH=$1
HUGGINGFACE_CACHE=$2
MODEL_NAME_PATH=$3
CUDA_BLOCKING=${4:-}

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/llmjp/"
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/"
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/"
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/"

# 並列処理でスクリプトを実行
CUDA_VISIBLE_DEVICES=0,1 bash "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_llmjp.sh" \
    "$REPO_PATH" "$HUGGINGFACE_CACHE" "$MODEL_NAME_PATH" \
    >  "${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/llmjp/${PBS_JOBID}.o" \
    2> "${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/llmjp/${PBS_JOBID}.e" &

CUDA_VISIBLE_DEVICES=2,3 bash "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_wmt20_enja.sh" \
    "$REPO_PATH" "$HUGGINGFACE_CACHE" "$MODEL_NAME_PATH" \
    >  "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/${PBS_JOBID}.o" \
    2> "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/${PBS_JOBID}.e" &

CUDA_VISIBLE_DEVICES=4,5 bash "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_wmt20_jaen.sh" \
    "$REPO_PATH" "$HUGGINGFACE_CACHE" "$MODEL_NAME_PATH" \
    >  "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/${PBS_JOBID}.o" \
    2> "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/${PBS_JOBID}.e" &

CUDA_VISIBLE_DEVICES=6,7 bash "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_mt_bench.sh" \
    "$REPO_PATH" "$HUGGINGFACE_CACHE" "$MODEL_NAME_PATH" 2 \
    >  "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/${PBS_JOBID}.o" \
    2> "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/${PBS_JOBID}.e" &

# すべてのジョブが終了するまで待つ
wait
