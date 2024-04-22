REPO_PATH="/gs/fs/tga-okazaki/tga-ohi/jalm-evaluation-private"
GROUP_ID="tga-okazaki"
HUGGINGFACE_CACHE="/gs/fs/tga-okazaki/tga-ohi/.cache"

MODEL_ID=$1

# Japanese
## llmjp
mkdir -p "$REPO_PATH/results/$MODEL_ID/ja/llmjp/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_ID/ja/llmjp/" -e "$REPO_PATH/results/$MODEL_ID/ja/llmjp/" "$REPO_PATH/scripts/tsubame/gpu_1/evaluate_ja_llmjp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_ID

## wmt20
mkdir -p "$REPO_PATH/results/$MODEL_ID/ja/wmt20_en_ja/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_ID/ja/wmt20_en_ja/" -e "$REPO_PATH/results/$MODEL_ID/ja/wmt20_en_ja/" "$REPO_PATH/scripts/tsubame/gpu_1/evaluate_ja_wmt20_enja.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_ID
mkdir -p "$REPO_PATH/results/$MODEL_ID/ja/wmt20_ja_en/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_ID/ja/wmt20_ja_en/" -e "$REPO_PATH/results/$MODEL_ID/ja/wmt20_ja_en/" "$REPO_PATH/scripts/tsubame/gpu_1/evaluate_ja_wmt20_jaen.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_ID

## xlsum
mkdir -p "$REPO_PATH/results/$MODEL_ID/ja/xlsum/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_ID/ja/xlsum/" -e "$REPO_PATH/results/$MODEL_ID/ja/xlsum/" "$REPO_PATH/scripts/tsubame/gpu_1/evaluate_ja_xlsum.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_ID

## mgsm
mkdir -p "$REPO_PATH/results/$MODEL_ID/ja/mgsm/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_ID/ja/mgsm/" -e "$REPO_PATH/results/$MODEL_ID/ja/mgsm/" "$REPO_PATH/scripts/tsubame/gpu_1/evaluate_ja_mgsm.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_ID

## mt_bench
mkdir -p "$REPO_PATH/results/$MODEL_ID/ja/ja_mt_bench/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_ID/ja/ja_mt_bench/" -e "$REPO_PATH/results/$MODEL_ID/ja/ja_mt_bench/" "$REPO_PATH/scripts/tsubame/gpu_1/evaluate_ja_mt_bench.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_ID 1

## jhumaneval
mkdir -p "$REPO_PATH/results/$MODEL_ID/ja/humaneval/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_ID/ja/humaneval/" -e "$REPO_PATH/results/$MODEL_ID/ja/humaneval/" "$REPO_PATH/scripts/tsubame/gpu_1/evaluate_ja_humaneval.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_ID

# English
mkdir -p "$REPO_PATH/results/$MODEL_ID/en/harness_en/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_ID/en/harness_en/" -e "$REPO_PATH/results/$MODEL_ID/en/harness_en" "$REPO_PATH/scripts/tsubame/gpu_1/evaluate_english.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_ID

## humaneval
mkdir -p "$REPO_PATH/results/$MODEL_ID/en/humaneval/"
qsub -g $GROUP_ID -o "$REPO_PATH/results/$MODEL_ID/en/humaneval/" -e "$REPO_PATH/results/$MODEL_ID/en/humaneval" "$REPO_PATH/scripts/tsubame/gpu_1/evaluate_english_humaneval.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_ID