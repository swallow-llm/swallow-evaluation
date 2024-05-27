#!/bin/bash
#YBATCH -r a100_1
#SBATCH --nodes 1
#SBATCH -J english
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
source .venv_harness_en/bin/activate
export TOKENIZERS_PARALLELISM=false

# This script is used to evaluate
# triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squad2
# to evaluate with all testcases, set NUM_TESTCASE=None

MODEL_NAME_PATH=$1
TASK_NAME="triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squad2"
NUM_FEWSHOT=$2
NUM_TESTCASE="all"
OUTDIR="results/${MODEL_NAME_PATH}/en/alltasks_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

mkdir -p $OUTDIR

python lm-evaluation-harness-en/main.py \
    --model hf-causal-experimental \
    --model_args pretrained=$MODEL_NAME_PATH \
    --tasks $TASK_NAME \
    --num_fewshot $NUM_FEWSHOT \
    --max_batch_size 1 \
    --write_out \
    --device cuda \
    --output_base_path $OUTDIR \
    --output_path ${OUTDIR}/score.json
