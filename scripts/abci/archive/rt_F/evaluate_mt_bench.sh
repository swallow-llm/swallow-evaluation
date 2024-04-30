#!/bin/bash
#$ -l rt_AG.small=1
#$ -l h_rt=72:00:00
#$ -j y
#$ -o outputs-full/
#$ -cwd

# module load
source /etc/profile.d/modules.sh
module load python/3.10/3.10.10
module load cuda/11.8/11.8.0
module load cudnn/8.9/8.9.2
module load nccl/2.16/2.16.2-1
module load hpcx/2.12

export HUGGINGFACE_HUB_CACHE=/home/acf15321wt/gcb50243/ohi/.cache
export HF_HOME=/home/acf15321wt/gcb50243/ohi/.cache

cd /home/acf15321wt/jalm-evaluation-private/

source .venv_fastchat/bin/activate

MODEL_NAME_PATH=$1

OUTDIR="results/${MODEL_NAME_PATH}/ja/ja_mt_bench"
mkdir -p ${OUTDIR}

cd fastchat/fastchat/llm_judge
python gen_model_answer.py --model-path ${MODEL_NAME_PATH} --model-id ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --num-choices 5 --num-gpus-total 4 --num-gpus-per-model 4
python gen_judgment.py --model-list ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --parallel 2
python show_result.py --model-list ${MODEL_NAME_PATH} --bench-name japanese_mt_bench --output-file ../../../${OUTDIR}/judge.json
cd ../../../