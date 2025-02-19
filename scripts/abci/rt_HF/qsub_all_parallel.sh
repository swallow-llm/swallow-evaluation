source ~/.bashrc

ROOT_PATH=$SWALLOW_EVAL_ROOT
HUGGINGFACE_CACHE=$SWALLOW_EVAL_HUGGINGFACE_CACHEDIR
GROUP_ID="gag51395"

MODEL_NAME_PATH=$1

# group_1: ja_mgsm, wmt20_jaen, wmt20_enja, humaneval-unstripped
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=12:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GROUP_1 -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/groups/evaluate_group_1.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# group_2: ja_humaneval-unstripped, mbpp, ja_mbpp, english_mmlu
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=12:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GROUP_2 -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/groups/evaluate_group_2.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# group_3: gpqa, english_math, ja_xlsum
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=12:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GROUP_3 -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/groups/evaluate_group_3.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# group_4: llmjp, english_general, english_bbh, mt-bench
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=12:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GROUP_4 -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/groups/evaluate_group_4.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
