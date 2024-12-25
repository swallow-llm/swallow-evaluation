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
MODEL_NAME_PATH=$3
CUDA_BLOCKING=${4:-}

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

# Set CUDA_LAUNCH_BLOCKING to prevent evaluation from stopping at a certain batch
# (This setting should be done only if necessary because it might slow evaluation)
if [ -n "$CUDA_BLOCKING" ]; then
  export CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING
else
  unset CUDA_LAUNCH_BLOCKING
fi
echo CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING

cd $REPO_PATH

source .venv_harness_en/bin/activate

OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/en/harness_en"
mkdir -p $OUTDIR

GENERAL_TASK_NAME="triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squadv2"
GENERAL_NUM_FEWSHOT=4
GENERAL_NUM_TESTCASE="all"
GENERAL_OUTDIR="${OUTDIR}/alltasks_${GENERAL_NUM_FEWSHOT}shot_${GENERAL_NUM_TESTCASE}cases/general"

MMLU_TASK_NAME="mmlu"
MMLU_NUM_FEWSHOT=5
MMLU_NUM_TESTCASE="all"
MMLU_OUTDIR="${OUTDIR}/alltasks_${MMLU_NUM_FEWSHOT}shot_${MMLU_NUM_TESTCASE}cases/mmlu"

BBH_TASK_NAME="bbh_cot_fewshot"
BBH_NUM_FEWSHOT=3
BBH_NUM_TESTCASE="all"
BBH_OUTDIR="${OUTDIR}/alltasks_${BBH_NUM_FEWSHOT}shot_${BBH_NUM_TESTCASE}cases/bbh_cot"

GPQA_TASK_NAME="gpqa_main_cot_zeroshot_meta_llama3_wo_chat"
GPQA_NUM_FEWSHOT=0
GPQA_NUM_TESTCASE="all"
GPQA_OUTDIR="results/${MODEL_NAME_PATH}/en/harness_en/alltasks_${GPQA_NUM_FEWSHOT}shot_${GPQA_NUM_TESTCASE}cases/gpqa_main_cot_zeroshot_meta_llama3_wo_chat"

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast_tokenizer=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=False
else
    USE_FAST_TOKENIZER=True
fi

mkdir -p $GENERAL_OUTDIR
mkdir -p $MMLU_OUTDIR
mkdir -p $BBH_OUTDIR

cd lm-evaluation-harness-en

echo $MMLU_TASK_NAME
lm_eval --model hf \
    --model_args "pretrained=$MODEL_NAME_PATH,parallelize=True,trust_remote_code=True,use_fast_tokenizer=$USE_FAST_TOKENIZER" \
    --tasks $MMLU_TASK_NAME \
    --num_fewshot $MMLU_NUM_FEWSHOT \
    --batch_size 4 \
    --device cuda \
    --write_out \
    --output_path "$MMLU_OUTDIR" \
    --use_cache "$MMLU_OUTDIR" \
    --log_samples \
    --seed 42 \

lm_eval --model hf \
    --model_args "pretrained=$MODEL_NAME_PATH,parallelize=True,trust_remote_code=True,use_fast_tokenizer=$USE_FAST_TOKENIZER" \
    --tasks $BBH_TASK_NAME \
    --num_fewshot $BBH_NUM_FEWSHOT \
    --batch_size 8 \
    --device cuda \
    --write_out \
    --output_path "$BBH_OUTDIR" \
    --use_cache "$BBH_OUTDIR" \
    --log_samples \
    --seed 42 \

lm_eval --model hf \
    --model_args "pretrained=$MODEL_NAME_PATH,parallelize=True,trust_remote_code=True,use_fast_tokenizer=$USE_FAST_TOKENIZER" \
    --tasks $GENERAL_TASK_NAME \
    --num_fewshot $GENERAL_NUM_FEWSHOT \
    --batch_size 8 \
    --device cuda \
    --write_out \
    --output_path "$GENERAL_OUTDIR" \
    --use_cache "$GENERAL_OUTDIR" \
    --log_samples \
    --seed 42 \

lm_eval --model hf \
    --model_args "pretrained=$MODEL_NAME_PATH,parallelize=True,trust_remote_code=True,use_fast_tokenizer=$USE_FAST_TOKENIZER" \
    --tasks $GPQA_TASK_NAME \
    --num_fewshot $GPQA_NUM_FEWSHOT \
    --batch_size 8 \
    --device cuda \
    --write_out \
    --output_path "$GPQA_OUTDIR" \
    --use_cache "$GPQA_OUTDIR" \
    --log_samples \
    --seed 42 \

# aggregate results
cd ../
python scripts/aggregate_result.py --model $MODEL_NAME_PATH


