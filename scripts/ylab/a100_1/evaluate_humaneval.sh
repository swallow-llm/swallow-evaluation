#!/bin/bash
#YBATCH -r a100_1
#SBATCH --nodes 1
#SBATCH -J humaneval
#SBATCH --time=168:00:00
#SBATCH --output outputs/%j.out
#SBATCH --error errors/%j.err

. /etc/profile.d/modules.sh
module load cuda/11.8
module load cudnn/cuda-11.x/8.9.0
module load nccl/cuda-11.7/2.14.3
module load openmpi/4.0.5
module load singularity

export HF_HOME=/home/ishida/.cache
export HF_DATASETS_CACHE=/home/ishida/HF_DATASETS_CACHE
export TRANSFORMERS_CACHE=/home/ishida/TRANSFORMERS_CACHE

# running llm-jp-eval for basic japanese task
source .venv_bigcode/bin/activate

export MASTER_ADDR=localhost
MODEL_NAME_PATH=$1
DO_GENERATION=$2
DO_EVAL=$3
USERNAME=$4 # ラボサーバーでのユーザー名を指定してください
NUM_SAMPLES=10
BATCH_SIZE=10
OUTDIR="results/${MODEL_NAME_PATH}/ja/humaneval"

mkdir -p $OUTDIR

if [ ${DO_GENERATION} = "true" ]; then
  echo "Generating"
  python bigcode-evaluation-harness/main.py \
    --model ${MODEL_NAME_PATH} \
    --tasks jhumaneval \
    --do_sample True \
    --n_samples ${NUM_SAMPLES} \
    --batch_size ${BATCH_SIZE} \
    --save_generations \
    --generation_only \
    --save_generations_path ${OUTDIR}/generation.json \
    --use_auth_token \
    --max_memory_per_gpu auto \
    --trust_remote_code \
    --max_length_generation 1024
fi

if [ ${DO_EVAL} = "true" ]; then
  echo "Evaluating"
  echo "Generated codes should be place at $(pwd)/${OUTDIR}/generation_jhumaneval.json ."
  touch $(pwd)/${OUTDIR}/metrics.json

  singularity exec \
    --bind $(pwd)/${OUTDIR}/generation_jhumaneval.json:/app/generations_py.json \
    --bind $(pwd)/${OUTDIR}/metrics.json:/app/metrics.json \
    /home/${USERNAME}/jalm-evaluation-private/bigcode-evaluation-harness/evaluation-harness_latest.sif \
    python3 bigcode-evaluation-harness/main.py \
    --model ${MODEL_NAME_PATH} \
    --tasks humaneval \
    --load_generations_path /app/generations_py.json \
    --allow_code_execution \
    --n_samples ${NUM_SAMPLES} \
    --metric_output_path /app/metrics.json

  python bigcode-evaluation-harness/bigcode_eval/custom_utils.py --generation_path $(pwd)/${OUTDIR}/generation_jhumaneval.json --metrics_path $(pwd)/${OUTDIR}/metrics.json
fi

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH

echo "Done"