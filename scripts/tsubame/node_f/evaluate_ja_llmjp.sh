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

source .venv_llm_jp_eval/bin/activate

OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/llmjp"
mkdir -p ${OUTDIR}

DATASET_DIR="llm-jp-eval/dataset/1.3.0/evaluation/test"
NUM_TESTCASE=-1
GENERAL_NUM_FEWSHOT=4
JMMLU_NUM_FEWSHOT=5

GENERAL_OUTDIR="${OUTDIR}/${GENERAL_NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"
JMMLU_OUTDIR="${OUTDIR}/${JMMLU_NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

# MODEL_NAME_PATHにsarashina2が含まれているとき,use_fast_tokenizer=Falseが指定される
if [[ $MODEL_NAME_PATH == *"sarashina2"* ]]; then
    USE_FAST_TOKENIZER=False
else
    USE_FAST_TOKENIZER=True
fi

mkdir -p $GENERAL_OUTDIR
mkdir -p $JMMLU_OUTDIR

start_time=$(date +%s)
python llm-jp-eval/scripts/evaluate_llm.py -cn config_no-sample.yaml \
  model.pretrained_model_name_or_path=$MODEL_NAME_PATH \
  tokenizer.pretrained_model_name_or_path=$MODEL_NAME_PATH \
  tokenizer.use_fast=$USE_FAST_TOKENIZER \
  metainfo.max_num_samples=$NUM_TESTCASE \
  target_dataset="[\"jamp\", \"janli\", \"jemhopqa\", \"jcommonsenseqa\", \"jnli\", \"jsem\", \"jsick\", \"jsquad\", \"jsts\", \"niilc\"]" \
  metainfo.num_few_shots=$GENERAL_NUM_FEWSHOT \
  dataset_dir=$DATASET_DIR \
  log_dir=$GENERAL_OUTDIR \
  wandb.run_name=llm_jp_eval_general
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Evaluation General time: ${execution_time} seconds"

start_time=$(date +%s)
python llm-jp-eval/scripts/evaluate_llm.py -cn config_no-sample.yaml \
  model.pretrained_model_name_or_path=$MODEL_NAME_PATH \
  tokenizer.pretrained_model_name_or_path=$MODEL_NAME_PATH \
  tokenizer.use_fast=$USE_FAST_TOKENIZER \
  metainfo.max_num_samples=$NUM_TESTCASE \
  target_dataset="jmmlu" \
  metainfo.num_few_shots=$JMMLU_NUM_FEWSHOT \
  dataset_dir=$DATASET_DIR \
  log_dir=$JMMLU_OUTDIR \
  wandb.run_name=llm_jp_eval_jmmlu
end_time=$(date +%s)
execution_time=$((end_time - start_time))
echo "Evaluation JMMLU time: ${execution_time} seconds"

python llm-jp-eval/scripts/jmmlu_statistics.py --pred_path $JMMLU_OUTDIR

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH
