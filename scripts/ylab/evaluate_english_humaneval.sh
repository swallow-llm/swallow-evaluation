#!/bin/bash
#YBATCH -r a100_4
#SBATCH --nodes 1
#SBATCH -J en_human_eval
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

source .venv_bigcode/bin/activate


MODEL_NAME_PATH=$1
NUM_SAMPLES=$2
BATCH_SIZE=1
OUTDIR="results/${MODEL_NAME_PATH}/en/humaneval_${NUM_SAMPLES}NUM_SAMPLES_${BATCH_SIZE}BATCH_SIZE"

mkdir -p $OUTDIR

python bigcode-evaluation-harness/main.py \
  --model ${MODEL_NAME_PATH} \
  --tasks humaneval \
  --do_sample True \
  --trust_remote_code \
  --n_samples ${NUM_SAMPLES} \
  --batch_size ${BATCH_SIZE} \
  --save_generations \
  --generation_only \
  --save_generations_path ${OUTDIR}/generation.json \
  --max_memory_per_gpu auto \
  --precision bf16 \

echo "Done!"