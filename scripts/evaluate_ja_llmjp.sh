#!/bin/bash

# running llm-jp-eval for basic japanese task
source .venv_llm_jp_eval/bin/activate

MODEL_NAME_PATH=$1
TOKENIZER_NAME_PATH=$2
NUM_FEWSHOT=$3
NUM_TESTCASE=$4
DATASET_DIR="llm-jp-eval/datasets/evaluation/dev"

OUTDIR="results/${MODEL_NAME_PATH}/ja/llmjp_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

python llm-jp-eval/scripts/evaluate_llm.py -cn config.yaml \
  model.pretrained_model_name_or_path=$MODEL_NAME_PATH \
  tokenizer.pretrained_model_name_or_path=$TOKENIZER_NAME_PATH \
  max_num_samples=$NUM_TESTCASE \
  target_dataset="all" \
  num_few_shots=$NUM_FEWSHOT \
  dataset_dir=$DATASET_DIR \
  log_dir=$OUTDIR
