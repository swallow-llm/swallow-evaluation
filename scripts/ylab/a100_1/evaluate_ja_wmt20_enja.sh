#!/bin/bash
#YBATCH -r a100_1
#SBATCH --nodes 1
#SBATCH -J wmt20_enja
#SBATCH --time=168:00:00
#SBATCH --output outputs/%j.out
#SBATCH --error errors/%j.err

. /etc/profile.d/modules.sh
module load cuda/11.7
module load cudnn/cuda-11.x/8.9.0
module load nccl/cuda-11.7/2.14.3
module load openmpi/4.0.5

export HF_HOME=/home/tn/.cache
export HF_DATASETS_CACHE=/home/tn/HF_DATASETS_CACHE
export TRANSFORMERS_CACHE=/home/tn/TRANSFORMERS_CACHE


# running lm-evaluation-harness-jp for wmt20 task
source .venv_harness_jp/bin/activate
export TOKENIZERS_PARALLELISM=false

MODEL_NAME_PATH=$1
NUM_FEWSHOT=$2

OUTDIR="results/${MODEL_NAME_PATH}/ja/wmt20_en_ja_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args pretrained=$MODEL_NAME_PATH \
    --tasks "wmt20-en-ja" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 1 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_wmt20_en_ja.json
