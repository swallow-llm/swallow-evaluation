#!/bin/bash
#$ -l rt_AF=1
#$ -l h_rt=6:00:00
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


# running lm-evaluation-harness-jp for mgsm task

source .venv_harness_jp/bin/activate
export TOKENIZERS_PARALLELISM=false

MODEL_NAME_PATH=$1
NUM_FEWSHOT=$2
NUM_TESTCASE=all

OUTDIR="results/${MODEL_NAME_PATH}/ja/xlsum_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"

python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args pretrained=$MODEL_NAME_PATH,use_accelerate=True,dtype="bfloat16" \
    --tasks "xlsum_ja" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 1 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_xlsum.json