REPO_PATH="/home/acb11709gz/jalm-evaluation-private"
GROUP_ID="gag51395"
HUGGINGFACE_CACHE="/groups/gag51395/eval-checkpoints/"
LOCAL_PATH="/home/ma.y/jalm-evaluation-private/abci_humaneval_result/"

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
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_xlsum.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# ## mgsm
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_mgsm.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# ## mt_bench
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_mt_bench.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH 4

# jhumaneval
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval/" "$REPO_PATH/scripts/abci/rt_AF/evaluate_ja_humaneval.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "${LOCAL_PATH}/${MODEL_NAME_PATH}/ja/humaneval"

# English
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/abci/rt_AF/evaluate_english.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# # ## humaneval
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval/"
qsub -g $GROUP_ID -o "$REPO_PATH/resulqts/$MODEL_NAME_PATH/en/humaneval/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval" "$REPO_PATH/scripts/abci/rt_AF/evaluate_english_humaneval.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "${LOCAL_PATH}/${MODEL_NAME_PATH}/en/humaneval"