#!/bin/bash
#$ -l rt_AG.small=1
#$ -l h_rt=12:00:00
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

export HF_HOME=/bb/llm/gaf51275/jalm/.cache
export HF_DATASETS_CACHE=/bb/llm/gaf51275/jalm/.cache
export TRANSFORMERS_CACHE=/bb/llm/gaf51275/jalm/.cache

# running llm-jp-eval for basic japanese task
source .venv_llm_jp_eval/bin/activate

MODEL_NAME_PATH=$1
TOKENIZER_NAME_PATH=$2
NUM_FEWSHOT=$3
NUM_TESTCASE=$4
DATASET_DIR="llm-jp-eval/datasets/evaluation/test"

OUTDIR="results/${MODEL_NAME_PATH}/ja/llmjp_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

python llm-jp-eval/scripts/evaluate_llm.py -cn config.yaml \
  model.pretrained_model_name_or_path=$MODEL_NAME_PATH \
  tokenizer.pretrained_model_name_or_path=$TOKENIZER_NAME_PATH \
  max_num_samples=$NUM_TESTCASE \
  target_dataset="all" \
  num_few_shots=$NUM_FEWSHOT \
  dataset_dir=$DATASET_DIR \
  log_dir=$OUTDIR
