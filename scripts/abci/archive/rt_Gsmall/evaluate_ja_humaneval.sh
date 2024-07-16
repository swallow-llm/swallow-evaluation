#!/bin/bash
#$ -l rt_G.small=1
#$ -l h_rt=24:00:00
#$ -j y
#$ -o outputs-full/
#$ -cwd

# module load
source /etc/profile.d/modules.sh
module load python/3.10/3.10.10
module load cuda/11.8/11.8.0
module load cudnn/8.9/8.9.2
module load nccl/2.16/2.16.2-1
module load hpcx/2.12

export HUGGINGFACE_HUB_CACHE=/home/acf15321wt/gcb50243/ohi/.cache
export HF_HOME=/home/acf15321wt/gcb50243/ohi/.cache

# running llm-jp-eval for basic japanese task
source .venv_bigcode/bin/activate

MODEL_NAME_PATH=$1
NUM_SAMPLES=10
BATCH_SIZE=10
OUTDIR="results/${MODEL_NAME_PATH}/ja/humaneval"

python bigcode-evaluation-harness/main.py \
  --model ${MODEL_NAME_PATH} \
  --tasks jhumaneval \
  --do_sample True \
  --n_samples ${NUM_SAMPLES} \
  --batch_size ${BATCH_SIZE} \
  --allow_code_execution \
  --save_generations \
  --generation_only \
  --save_generations_path ${OUTDIR}/generation.json \
  --use_auth_token \
  --max_memory_per_gpu auto \
  --trust_remote_code
