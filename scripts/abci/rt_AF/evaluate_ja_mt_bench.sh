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
MODEL_ID=$3
GPU_NUM=$4

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

cd $REPO_PATH

source .venv_fastchat/bin/activate

OUTDIR="${REPO_PATH}/results/${MODEL_ID}/ja/ja_mt_bench"
mkdir -p $OUTDIR

cd fastchat/fastchat/llm_judge
python gen_model_answer.py --model-path ${MODEL_ID} --model-id ${MODEL_ID} --bench-name japanese_mt_bench --num-choices 5 --num-gpus-total $GPU_NUM --num-gpus-per-model $GPU_NUM
python gen_judgment.py --model-list ${MODEL_ID} --bench-name japanese_mt_bench --parallel 4
python show_result.py --model-list ${MODEL_ID} --bench-name japanese_mt_bench --output-file ${OUTDIR}/judge.json

# aggregate results
cd ../../../
python scripts/aggregate_result.py --model $MODEL_ID
