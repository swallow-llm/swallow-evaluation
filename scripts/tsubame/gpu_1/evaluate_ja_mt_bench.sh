#!/bin/bash
#$ -cwd

#$ -l gpu_1=1
#$ -l h_rt=24:00:00

# module load
. /etc/profile.d/modules.sh
module load cuda/12.1.0
module load cudnn/9.0.0

REPO_PATH=$1
HUGGINGFACE_CACHE=$2
MODEL_NAME_PATH=$3
GPU_NUM=$4

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

cd $REPO_PATH

source .venv_fastchat/bin/activate

OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/ja_mt_bench"
mkdir -p $OUTDIR

cd fastchat/fastchat/llm_judge
python gen_model_answer.py --model-path ${MODEL_NAME_PATH} --model-id ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --num-choices 5 --num-gpus-total $GPU_NUM --num-gpus-per-model $GPU_NUM
python gen_judgment.py --model-list ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --parallel 4
python show_result.py --model-list ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --output-file ${OUTDIR}/judge.json

# aggregate results
cd ../../../
python scripts/aggregate_result.py --model $MODEL_NAME_PATH
