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

cd $REPO_PATH

source .venv_harness_jp/bin/activate

NUM_FEWSHOT=1
NUM_TESTCASE="all"
OUTDIR="${REPO_PATH}/results/${MODEL_NAME_PATH}/ja/xlsum/xlsum_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"
mkdir -p ${OUTDIR}
export CUDA_LAUNCH_BLOCKING=1

python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args "pretrained=$MODEL_NAME_PATH,use_accelerate=True" \
    --tasks "xlsum_ja" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 2 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_xlsum.json \
    --use_cache ${OUTDIR}

# aggregate results
python scripts/aggregate_result.py --model $MODEL_NAME_PATH
