#!/bin/bash
#$ -cwd

#$ -l node_f=1
#$ -l h_rt=24:00:00

# module load
. /etc/profile.d/modules.sh
module load cuda/12.1.0
module load cudnn/9.0.0

REPO_PATH=$1
HUGGINGFACE_CACHE=$2
MODEL_NAME_PATH=$3
GPU_NUM=$4
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

source .venv_fastchat/bin/activate

OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/ja_mt_bench"
mkdir -p ${OUTDIR}

cd fastchat/fastchat/llm_judge

echo "Generating model answers"
start_time=$(date +%s)
python gen_model_answer.py \
  --model-path ${MODEL_NAME_PATH} \
  --model-id ${MODEL_NAME_PATH} \
  --bench-name japanese_mt_bench \
  --num-choices 5 \
  --num-gpus-total $GPU_NUM \
  --num-gpus-per-model $GPU_NUM
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Generation model answers time: ${execution_time} seconds"

echo "Generating judgements"
start_time=$(date +%s)
python gen_judgment.py \
  --model-list ${MODEL_NAME_PATH} \
  --bench-name japanese_mt_bench \
  --parallel 4 \
  --judge-model gpt-4-1106-preview
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Generation judgements time: ${execution_time} seconds"

python show_result.py \
  --model-list ${MODEL_NAME_PATH} \
  --bench-name japanese_mt_bench \
  --output-file ${OUTDIR}/judge.json \
  --judge-model gpt-4-1106-preview

# aggregate results
cd ../../../
python scripts/aggregate_result.py --model $MODEL_NAME_PATH
