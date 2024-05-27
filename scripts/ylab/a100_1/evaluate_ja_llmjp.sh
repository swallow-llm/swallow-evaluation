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

MODEL_NAME_PATH=$1
TOKENIZER_NAME_PATH=$2
DATASET_DIR="llm-jp-eval/dataset/1.3.0/evaluation/test"
NUM_TESTCASE=-1
GENERAL_NUM_FEWSHOT=4
JMMLU_NUM_FEWSHOT=5

GENERAL_OUTDIR="results/${MODEL_NAME_PATH}/ja/llmjp/${GENERAL_NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"
JMMLU_OUTDIR="results/${MODEL_NAME_PATH}/ja/llmjp/${JMMLU_NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

mkdir -p $GENERAL_OUTDIR
mkdir -p $JMMLU_OUTDIR

python llm-jp-eval/scripts/evaluate_llm.py -cn config_no-sample.yaml \
  model.pretrained_model_name_or_path=$MODEL_NAME_PATH \
  tokenizer.pretrained_model_name_or_path=$TOKENIZER_NAME_PATH \
  metainfo.max_num_samples=$NUM_TESTCASE \
  target_dataset="[\"jamp\", \"janli\", \"jemhopqa\", \"jcommonsenseqa\", \"jnli\", \"jsem\", \"jsick\", \"jsquad\", \"jsts\", \"niilc\"]" \
  metainfo.num_few_shots=$GENERAL_NUM_FEWSHOT \
  dataset_dir=$DATASET_DIR \
  log_dir=$GENERAL_OUTDIR \
  wandb.run_name=llm_jp_eval_general

python llm-jp-eval/scripts/evaluate_llm.py -cn config_no-sample.yaml \
  model.pretrained_model_name_or_path=$MODEL_NAME_PATH \
  tokenizer.pretrained_model_name_or_path=$TOKENIZER_NAME_PATH \
  metainfo.max_num_samples=$NUM_TESTCASE \
  target_dataset="jmmlu" \
  metainfo.num_few_shots=$JMMLU_NUM_FEWSHOT \
  dataset_dir=$DATASET_DIR \
  log_dir=$JMMLU_OUTDIR \
  wandb.run_name=llm_jp_eval_jmmlu

python llm-jp-eval/scripts/jmmlu_statistics.py --pred_path $JMMLU_OUTDIR

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH
