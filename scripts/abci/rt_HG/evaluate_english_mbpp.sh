#!/bin/bash

source ~/.bashrc
source /etc/profile.d/modules.sh

module load cuda/12.1/12.1.1
module load cudnn/9.5/9.5.1 

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

source .venv_bigcode/bin/activate

NUM_SAMPLES=10
BATCH_SIZE=3
OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/en/mbpp"
SINGULARITY_IMAGE="evaluation-harness_latest.sif"

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast_tokenizer=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=''
else
    USE_FAST_TOKENIZER='--use_fast_tokenizer'
fi

mkdir -p $OUTDIR


# # generate
# echo "Generating"
# start_time=$(date +%s)
# python bigcode-evaluation-harness/main.py \
#   --model ${MODEL_NAME_PATH} \
#   --tasks mbpp \
#   --do_sample True \
#   --n_samples ${NUM_SAMPLES} \
#   --batch_size ${BATCH_SIZE} \
#   --allow_code_execution \
#   --save_generations \
#   --generation_only \
#   --save_generations_path ${OUTDIR}/generation.json \
#   --use_auth_token \
#   --max_memory_per_gpu auto \
#   --trust_remote_code \
#   --max_length_generation 2048 \
#   --temperature 0.1 \
#   ${USE_FAST_TOKENIZER}
# end_time=$(date +%s)
# execution_time=$((end_time - start_time))
# echo "Generation time: ${execution_time} seconds"


# evaluate
echo "Evaluating"
echo "Generated codes should be placed at ${OUTDIR}/generation_mbpp.json ."
touch ${OUTDIR}/metrics.json
export HF_HOME=$REPO_PATH/HF_HOME

start_time=$(date +%s)
singularity run \
  -B ${OUTDIR}/generation_mbpp.json:/app/generations_py.json \
  -B ${OUTDIR}/metrics.json:/app/metrics.json \
  --pwd /app \
  ${SINGULARITY_IMAGE} \
  python3 main.py \
  --model ${MODEL_NAME_PATH} \
  --tasks mbpp \
  --load_generations_path /app/generations_py.json \
  --allow_code_execution \
  --n_samples 10 \
  --metric_output_path /app/metrics.json

python bigcode-evaluation-harness/bigcode_eval/custom_utils.py \
  --generation_path ${OUTDIR}/generation_mbpp.json \
  --metrics_path ${OUTDIR}/metrics.json \
  --task mbpp

end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Evaluation time: ${execution_time} seconds"


# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH