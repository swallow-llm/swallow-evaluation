#!/bin/bash

# running lm-evaluation-harness-jp for xlsum task
source .venv_harness_jp/bin/activate
export TOKENIZERS_PARALLELISM=false

MODEL_NAME_PATH=$1
CUDA_BLOCKING=${2:-}
NUM_FEWSHOT=1
NUM_TESTCASE="all"

# Set CUDA_LAUNCH_BLOCKING to prevent evaluation from stopping at a certain batch
# (This setting should be done only if necessary because it might slow evaluation)
if [ -n "$CUDA_BLOCKING" ]; then
  export CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING
else
  unset CUDA_LAUNCH_BLOCKING
fi
echo CUDA_LAUNCH_BLOCKING=$CUDA_BLOCKING

OUTDIR="results/${MODEL_NAME_PATH}/ja/xlsum/xlsum_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases"
mkdir -p $OUTDIR

echo ${OUTDIR}

echo "CUDA_LAUNCH_BLOCKING: $CUDA_LAUNCH_BLOCKING" >&2
start_time=$(date +%s)
python lm-evaluation-harness-jp/main.py \
    --model hf-causal-experimental \
    --model_args "pretrained=$MODEL_NAME_PATH,use_accelerate=True,trust_remote_code=True" \
    --tasks "xlsum_ja" \
    --num_fewshot $NUM_FEWSHOT \
    --batch_size 2 \
    --verbose \
    --device cuda \
    --output_path ${OUTDIR}/score_xlsum.json \
    --use_cache ${OUTDIR}
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# formatting
hours=$((elapsed_time / 3600))
minutes=$(( (elapsed_time % 3600) / 60 ))
seconds=$((elapsed_time % 60))

# output the elapsed time
echo "Elapsed time: ${hours}h ${minutes}m ${seconds}s" >&2

python scripts/aggregate_result.py --model $MODEL_NAME_PATH
