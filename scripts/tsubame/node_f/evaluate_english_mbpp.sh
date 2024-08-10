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
DO_GENERATION=$4
DO_EVAL=$5

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

cd $REPO_PATH

source .venv_bigcode/bin/activate

NUM_SAMPLES=10
BATCH_SIZE=10
OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/en/mbpp"

mkdir -p $OUTDIR

if [ ${DO_GENERATION} = "true" ]; then
  echo "Generating"
python bigcode-evaluation-harness/main.py \
    --model ${MODEL_NAME_PATH} \
    --tasks mbpp \
    --do_sample True \
    --n_samples ${NUM_SAMPLES} \
    --batch_size ${BATCH_SIZE} \
    --save_generations \
    --generation_only \
    --save_generations_path ${OUTDIR}/generation.json \
    --use_auth_token \
    --max_memory_per_gpu auto \
    --trust_remote_code \
    --max_length_generation 2048 \
    --temperature 0.1
fi

if [ ${DO_EVAL} = "true" ]; then
  echo "Evaluating"
  echo "Generated codes should be placed at ${OUTDIR}/generation_mbpp.json ."
  touch ${OUTDIR}/metrics.json
  export HF_HOME=$REPO_PATH/HF_HOME
  apptainer run \
    -B ${OUTDIR}/generation_mbpp.json:/app/generations_py.json \
    -B ${OUTDIR}/metrics.json:/app/metrics.json \
    --pwd /app \
    ${APPTAINER_IMAGE} \
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
fi

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH

