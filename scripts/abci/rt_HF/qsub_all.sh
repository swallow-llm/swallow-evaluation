REPO_PATH="/home/{username}/jalm-evaluation-private_2412_update-saito_dev_abci"
GROUP_ID="gag51395"
HUGGINGFACE_CACHE="/groups/gag51395/share/{name}/.cache"

MODEL_NAME_PATH=$1

# Japanese
# mt_bench
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MTBench -k oe --  "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_mt_bench.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH 4

# jhumaneval-unstripped
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_JHumanEvalUnstriped -k oe -- "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# mbpp-ja
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_JMBPP -k oe --  "$REPO_PATH/scripts/abci/rt_HF/evaluate_ja_mbpp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH


# English
# humaneval-unstripped
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_HumanEvalUnstriped -k oe -- "$REPO_PATH/scripts/abci/rt_HF/evaluate_english_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# mbpp
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/mbpp/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MBPP -k oe --  "$REPO_PATH/scripts/abci/rt_HF/evaluate_english_mbpp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH