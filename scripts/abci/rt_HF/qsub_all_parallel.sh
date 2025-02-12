source ~/.bashrc

REPO_PATH=$SWALLOW_EVAL_ROOT
HUGGINGFACE_CACHE=$SWALLOW_EVAL_HUGGINGFACE_CACHE
GROUP_ID="gag51395"

MODEL_NAME_PATH=$1

# group_1: llmjp, wmt20enja, wmt20jaen, xlsum
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=12:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GROUP_1 -k oe -- "$REPO_PATH/scripts/abci/rt_HF/groups/evaluate_group_1.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# group_2: mgsm, mt_bench, jhumaneval-unstripped, mbpp-ja
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=12:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GROUP_2 -k oe -- "$REPO_PATH/scripts/abci/rt_HF/groups/evaluate_group_2.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# group_3: en_general, mmlu, bbh, math
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=12:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GROUP_3 -k oe -- "$REPO_PATH/scripts/abci/rt_HF/groups/evaluate_group_3.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# group_4: gpqa, humaneval-unstripped, mbpp
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=12:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GROUP_4 -k oe -- "$REPO_PATH/scripts/abci/rt_HF/groups/evaluate_group_4.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH