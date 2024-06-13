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

source .venv_harness_en/bin/activate

# This script is used to evaluate
# triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squad2
# to evaluate with all testcases, set NUM_TESTCASE=None

MODEL_NAME_PATH=$1

GENERAL_TASK_NAME="triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squadv2"
GENERAL_NUM_FEWSHOT=4
GENERAL_NUM_TESTCASE="all"
GENERAL_OUTDIR="results/${MODEL_NAME_PATH}/en/harness_en/alltasks_${GENERAL_NUM_FEWSHOT}shot_${GENERAL_NUM_TESTCASE}cases/general"

MMLU_TASK_NAME="mmlu"
MMLU_NUM_FEWSHOT=5
MMLU_NUM_TESTCASE="all"
MMLU_OUTDIR="results/${MODEL_NAME_PATH}/en/harness_en/alltasks_${MMLU_NUM_FEWSHOT}shot_${MMLU_NUM_TESTCASE}cases/mmlu"

BBH_TASK_NAME="bbh_cot_fewshot"
BBH_NUM_FEWSHOT=3
BBH_NUM_TESTCASE="all"
BBH_OUTDIR="results/${MODEL_NAME_PATH}/en/harness_en/alltasks_${BBH_NUM_FEWSHOT}shot_${BBH_NUM_TESTCASE}cases/bbh_cot"

mkdir -p $GENERAL_OUTDIR
mkdir -p $MMLU_OUTDIR
mkdir -p $BBH_OUTDIR

cd lm-evaluation-harness-en

echo $MMLU_TASK_NAME
lm_eval --model hf \
    --model_args "pretrained=$MODEL_NAME_PATH,parallelize=True,trust_remote_code=True" \
    --tasks $MMLU_TASK_NAME \
    --num_fewshot $MMLU_NUM_FEWSHOT \
    --batch_size 16 \
    --device cuda \
    --write_out \
    --output_path "../$MMLU_OUTDIR" \
    --use_cache "../$MMLU_OUTDIR" \
    --seed 42 \

lm_eval --model hf \
    --model_args "pretrained=$MODEL_NAME_PATH,parallelize=True,trust_remote_code=True" \
    --tasks $BBH_TASK_NAME \
    --num_fewshot $BBH_NUM_FEWSHOT \
    --batch_size 16 \
    --device cuda \
    --write_out \
    --output_path "../$BBH_OUTDIR" \
    --use_cache "../$BBH_OUTDIR" \
    --log_samples \
    --seed 42 \

lm_eval --model hf \
    --model_args "pretrained=$MODEL_NAME_PATH,parallelize=True,trust_remote_code=True" \
    --tasks $GENERAL_TASK_NAME \
    --num_fewshot $GENERAL_NUM_FEWSHOT \
    --batch_size 16 \
    --device cuda \
    --write_out \
    --output_path "../$GENERAL_OUTDIR" \
    --use_cache "../$GENERAL_OUTDIR" \
    --log_samples \
    --seed 42 \

# aggregate results
cd ../
python scripts/aggregate_result.py --model $MODEL_NAME_PATH
