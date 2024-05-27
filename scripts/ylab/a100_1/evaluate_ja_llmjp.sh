#!/bin/bash
#YBATCH -r a100_1
#SBATCH --nodes 1
#SBATCH -J ja_llmjp
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

# running llm-jp-eval for basic japanese task
source .venv_llm_jp_eval/bin/activate
export TOKENIZERS_PARALLELISM=false

MODEL_NAME_PATH=$1
TOKENIZER_NAME_PATH=$2
NUM_FEWSHOT=$3
NUM_TESTCASE=$4
DATASET_DIR="llm-jp-eval/dataset/evaluation/test"

OUTDIR="results/${MODEL_NAME_PATH}/ja/llmjp_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

python llm-jp-eval/scripts/evaluate_llm.py -cn config.yaml \
  model.pretrained_model_name_or_path=$MODEL_NAME_PATH \
  tokenizer.pretrained_model_name_or_path=$TOKENIZER_NAME_PATH \
  max_num_samples=$NUM_TESTCASE \
  target_dataset="all" \
  num_few_shots=$NUM_FEWSHOT \
  dataset_dir=$DATASET_DIR \
  log_dir=$OUTDIR
