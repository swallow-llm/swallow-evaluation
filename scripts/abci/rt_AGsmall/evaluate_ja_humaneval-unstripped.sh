#!/bin/bash

#$ -l rt_AG.small=1
#$ -l h_rt=24:00:00
#$ -j y
#$ -cwd

source ~/.bashrc
source /etc/profile.d/modules.sh
conda deactivate
module load python/3.10/3.10.14
module load cuda/12.1/12.1.1
module load cudnn/9.0/9.0.0

REPO_PATH=$1
HUGGINGFACE_CACHE=$2
MODEL_NAME_PATH=$3
LOCAL_PATH=$4
CUDA_BLOCKING=${5:-}

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

source .venv_bigcode/bin/activate

NUM_SAMPLES=10
BATCH_SIZE=1
OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/humaneval-unstripped"

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast_tokenizer=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=''
else
    USE_FAST_TOKENIZER='--use_fast_tokenizer'
fi

mkdir -p $OUTDIR

# generate

python bigcode-evaluation-harness/main.py \
  --model ${MODEL_NAME_PATH} \
  --tasks jhumaneval-unstripped \
  --do_sample True \
  --n_samples ${NUM_SAMPLES} \
  --batch_size ${BATCH_SIZE} \
  --allow_code_execution \
  --save_generations \
  --generation_only \
  --save_generations_path ${OUTDIR}/generation.json \
  --use_auth_token \
  --max_memory_per_gpu auto \
  --trust_remote_code \
  --max_length_generation 1024 \
  ${USE_FAST_TOKENIZER}

# evaluate

ssh hestia "mkdir -p ${LOCAL_PATH}"
scp ${OUTDIR}/generation_jhumaneval-unstripped.json hestia:${LOCAL_PATH}
ssh hestia "curl -X POST -F \"model_name=${MODEL_NAME_PATH}\" -F \"file=@${LOCAL_PATH}/generation_jhumaneval-unstripped.json\" -F \"task=humaneval\" http://localhost:5001/api" > ${OUTDIR}/metrics.json
python bigcode-evaluation-harness/bigcode_eval/custom_utils.py --generation_path ${OUTDIR}/generation_jhumaneval-unstripped.json --metrics_path ${OUTDIR}/metrics.json

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH