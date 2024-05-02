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
MODEL_ID=$3

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

cd $REPO_PATH

source .venv_harness_en/bin/activate

OUTDIR="${REPO_PATH}/results/${MODEL_ID}/en/harness_en"
mkdir -p $OUTDIR

GENERAL_TASK_NAME="triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squadv2"
GENERAL_NUM_FEWSHOT=4
GENERAL_NUM_TESTCASE="all"
GENERAL_OUTDIR="${OUTDIR}/alltasks_${GENERAL_NUM_FEWSHOT}shot_${GENERAL_NUM_TESTCASE}cases/general"

MMLU_TASK_NAME="mmlu"
MMLU_NUM_FEWSHOT=5
MMLU_NUM_TESTCASE="all"
MMLU_OUTDIR="${OUTDIR}/alltasks_${MMLU_NUM_FEWSHOT}shot_${MMLU_NUM_TESTCASE}cases/mmlu"

BBH_TASK_NAME="bbh_fewshot"
BBH_NUM_FEWSHOT=3
BBH_NUM_TESTCASE="all"
BBH_OUTDIR="${OUTDIR}/alltasks_${BBH_NUM_FEWSHOT}shot_${BBH_NUM_TESTCASE}cases/bbh"

mkdir -p $GENERAL_OUTDIR
mkdir -p $MMLU_OUTDIR
mkdir -p $BBH_OUTDIR

cd lm-evaluation-harness-en

echo $MMLU_TASK_NAME
accelerate launch --num_processes=1 --gpu_ids="0" -m lm_eval --model hf \
    --model_args pretrained=$MODEL_ID \
    --tasks $MMLU_TASK_NAME \
    --num_fewshot $MMLU_NUM_FEWSHOT \
    --batch_size auto \
    --max_batch_size 32 \
    --device cuda \
    --write_out \
    --output_path "$MMLU_OUTDIR" \
    --use_cache "$MMLU_OUTDIR" \
    --seed 42 \

accelerate launch --num_processes=1 --gpu_ids="0" -m lm_eval --model hf \
    --model_args pretrained=$MODEL_ID \
    --tasks $BBH_TASK_NAME \
    --num_fewshot $BBH_NUM_FEWSHOT \
    --batch_size auto \
    --max_batch_size 32 \
    --device cuda \
    --write_out \
    --output_path "$BBH_OUTDIR" \
    --use_cache "$BBH_OUTDIR" \
    --seed 42 \

accelerate launch --num_processes=1 --gpu_ids="0" -m lm_eval --model hf \
    --model_args pretrained=$MODEL_ID \
    --tasks $GENERAL_TASK_NAME \
    --num_fewshot $GENERAL_NUM_FEWSHOT \
    --batch_size auto \
    --max_batch_size 32 \
    --device cuda \
    --write_out \
    --output_path "$GENERAL_OUTDIR" \
    --use_cache "$GENERAL_OUTDIR" \
    --seed 42 \

# aggregate results
cd ../
python scripts/aggregate_result.py --model $MODEL_ID
