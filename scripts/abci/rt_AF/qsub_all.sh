REPO_PATH="/groups/gcb50243/maeda/jalm-evaluation-private"
GROUP_ID="gag51395"
HUGGINGFACE_CACHE="/groups/gag51395/share/ohi/.cache"
LOCAL_PATH="/home/ohi-m/jalm-evaluation-private-2404_update/abci_humaneval_result"

MODEL_NAME_PATH=$1

# Japanese
## llmjp
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/llmjp/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/llmjp/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/llmjp/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_llmjp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

## wmt20
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_wmt20_enja.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_wmt20_jaen.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

## xlsum
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_xlsum.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH 1

## mgsm
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_mgsm.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

## mt_bench
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_mt_bench.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH 8

# jhumaneval-unstripped
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "${LOCAL_PATH}/${MODEL_NAME_PATH}/ja/humaneval-unstripped"

# English
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/abci/rt_AF/evaluate_english.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# humaneval-unstripped
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped" "$REPO_PATH/scripts/abci/rt_AF/evaluate_english_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "${LOCAL_PATH}/${MODEL_NAME_PATH}/en/humaneval-unstripped"
