#!/bin/bash
#$ -l rt_AG.small=1
#$ -l h_rt=12:00:00
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

export HF_HOME=/bb/llm/gaf51275/jalm/.cache
export HF_DATASETS_CACHE=/bb/llm/gaf51275/jalm/.cache
export TRANSFORMERS_CACHE=/bb/llm/gaf51275/jalm/.cache

source .venv_harness_en/bin/activate

# This script is used to evaluate
# triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squad2
# to evaluate with all testcases, set NUM_TESTCASE=None

MODEL_NAME_PATH=$1
TASK_NAME="triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squad2"
NUM_FEWSHOT=$2
NUM_TESTCASE=all
OUTDIR="results/${MODEL_NAME_PATH}/en/alltasks_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

mkdir -p $OUTDIR

python lm-evaluation-harness-en/main.py \
    --model hf-causal-experimental \
    --model_args pretrained=$MODEL_NAME_PATH,use_accelerate=True,dtype="bfloat16" \
    --tasks $TASK_NAME \
    --num_fewshot $NUM_FEWSHOT \
    --max_batch_size 32 \
    --write_out \
    --device cuda \
    --output_base_path $OUTDIR \
    --output_path ${OUTDIR}/score.json
