#!/bin/bash
set -e

source ~/.bashrc
source /etc/profile.d/modules.sh

module load cuda/12.1/12.1.1
module load cudnn/9.5/9.5.1 

ROOT_PATH=$1
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

cd $ROOT_PATH

source .venv_harness_en/bin/activate

OUTDIR="${ROOT_PATH}/results/${MODEL_NAME_PATH}/en/harness_en"
mkdir -p ${OUTDIR}

GENERAL_TASK_NAME="triviaqa,gsm8k,openbookqa,hellaswag,xwinograd_en,squadv2"
GENERAL_NUM_FEWSHOT=4
GENERAL_NUM_TESTCASE="all"
GENERAL_OUTDIR="${OUTDIR}/alltasks_${GENERAL_NUM_FEWSHOT}shot_${GENERAL_NUM_TESTCASE}cases/general"

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast_tokenizer=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=False
else
    USE_FAST_TOKENIZER=True
fi

mkdir -p $GENERAL_OUTDIR

cd lm-evaluation-harness-en

echo "Generating: ${GENERAL_TASK_NAME}"
start_time=$(date +%s)
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
    --seed 42
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Generation time: ${execution_time} seconds"

# aggregate results
cd ../
python scripts/aggregate_result.py --model $MODEL_NAME_PATH
