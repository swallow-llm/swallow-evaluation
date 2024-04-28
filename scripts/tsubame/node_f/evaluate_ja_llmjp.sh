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
MODEL_ID=$3

export HUGGINGFACE_HUB_CACHE=$HUGGINGFACE_CACHE
export HF_HOME=$HUGGINGFACE_CACHE

cd $REPO_PATH

source .venv_llm_jp_eval/bin/activate

OUTDIR="${REPO_PATH}/results/${MODEL_ID}/ja/llmjp"
mkdir -p ${OUTDIR}

DATASET_DIR="llm-jp-eval/dataset/1.3.0/evaluation/test"
NUM_TESTCASE=-1
GENERAL_NUM_FEWSHOT=4
JMMLU_NUM_FEWSHOT=5

GENERAL_OUTDIR="${OUTDIR}/${GENERAL_NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"
JMMLU_OUTDIR="${OUTDIR}/${JMMLU_NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

python llm-jp-eval/scripts/evaluate_llm.py -cn config.yaml \
  model.pretrained_model_name_or_path=$MODEL_ID \
  tokenizer.pretrained_model_name_or_path=$MODEL_ID \
  metainfo.max_num_samples=$NUM_TESTCASE \
  target_dataset="[\"jamp\", \"janli\", \"jemhopqa\", \"jcommonsenseqa\", \"jnli\", \"jsem\", \"jsick\", \"jsquad\", \"jsts\", \"niilc\"]" \
  metainfo.num_few_shots=$GENERAL_NUM_FEWSHOT \
  dataset_dir=$DATASET_DIR \
  log_dir=$GENERAL_OUTDIR \
  wandb.run_name=llm_jp_eval_general

python llm-jp-eval/scripts/evaluate_llm.py -cn config.yaml \
  model.pretrained_model_name_or_path=$MODEL_ID \
  tokenizer.pretrained_model_name_or_path=$MODEL_ID \
  metainfo.max_num_samples=$NUM_TESTCASE \
  target_dataset="jmmlu" \
  metainfo.num_few_shots=$JMMLU_NUM_FEWSHOT \
  dataset_dir=$DATASET_DIR \
  log_dir=$JMMLU_OUTDIR \
  wandb.run_name=llm_jp_eval_jmmlu

# aggregate results
python scripts/aggregate_result.py --model $MODEL_ID
