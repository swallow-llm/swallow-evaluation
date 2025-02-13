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

mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/"
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/"
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/"
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp/"

# GPUモニタリングをバックグラウンドで実行
python3 "$REPO_PATH/scripts/monitor_gpu.py --output_path ~/.SE_${MODEL_NAME_PATH//\//_}_GPU_USAGE_GROUP_2.csv" > /dev/stdout 2>/dev/null &
MONITOR_PID=$!   # ここでPIDを取得しておく


# 並列処理でスクリプトを実行
CUDA_VISIBLE_DEVICES=0,1 bash "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_mgsm.sh" \
    "$REPO_PATH" "$HUGGINGFACE_CACHE" "$MODEL_NAME_PATH" \
    >  "${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/mgsm/${PBS_JOBID}.o" \
    2> "${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/mgsm/${PBS_JOBID}.e" &

CUDA_VISIBLE_DEVICES=2,3 bash "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_xlsum.sh" \
    "$REPO_PATH" "$HUGGINGFACE_CACHE" "$MODEL_NAME_PATH" \
    >  "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/${PBS_JOBID}.o" \
    2> "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/${PBS_JOBID}.e" &

CUDA_VISIBLE_DEVICES=4,5 bash "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_humaneval-unstripped.sh" \
    "$REPO_PATH" "$HUGGINGFACE_CACHE" "$MODEL_NAME_PATH" \
    >  "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/${PBS_JOBID}.o" \
    2> "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/${PBS_JOBID}.e" &

CUDA_VISIBLE_DEVICES=6,7 bash "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_mbpp.sh" \
    "$REPO_PATH" "$HUGGINGFACE_CACHE" "$MODEL_NAME_PATH" \
    >  "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp/${PBS_JOBID}.o" \
    2> "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp/${PBS_JOBID}.e" &

# すべてのジョブが終了するまで待つ
wait

# GPUモニタリングを停止
kill "$MONITOR_PID"
