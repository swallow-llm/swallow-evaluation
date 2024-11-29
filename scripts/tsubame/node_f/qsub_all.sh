REPO_PATH="/gs/fs/tga-okazaki/saito/jalm-evaluation-private"
HUGGINGFACE_CACHE="/gs/bs/tga-okazaki/saito/HF_HOME"
APPTAINER_CACHE="/gs/bs/tga-okazaki/saito/apptainer_chace"
QSUB_CMD="qsub -g tga-okazaki"
MODEL_NAME_PATH=$1

# Japanese
# # llmjp
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/llmjp/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/llmjp/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/llmjp/" "$REPO_PATH/scripts/tsubame/node_f/evaluate_ja_llmjp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# # wmt20
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/" "$REPO_PATH/scripts/tsubame/node_f/evaluate_ja_wmt20_enja.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/" "$REPO_PATH/scripts/tsubame/node_f/evaluate_ja_wmt20_jaen.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# # xlsum
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/" "$REPO_PATH/scripts/tsubame/node_f/evaluate_ja_xlsum.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# # mgsm
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/" "$REPO_PATH/scripts/tsubame/node_f/evaluate_ja_mgsm.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# # mt_bench
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/" "$REPO_PATH/scripts/tsubame/node_f/evaluate_ja_mt_bench.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH 4

# # jhumaneval-unstripped
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/" "$REPO_PATH/scripts/tsubame/node_f/evaluate_ja_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "true" "true" $APPTAINER_CACHE

# mbpp-ja
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp" "$REPO_PATH/scripts/tsubame/node_f/evaluate_ja_mbpp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "true" "true" $APPTAINER_CACHE


# English
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/"
$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/tsubame/node_f/evaluate_english_general.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/tsubame/node_f/evaluate_english_mmlu.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/tsubame/node_f/evaluate_english_bbh.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/tsubame/node_f/evaluate_english_math.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# # humaneval-unstripped
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped" "$REPO_PATH/scripts/tsubame/node_f/evaluate_english_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "true" "true" $APPTAINER_CACHE

# # mbpp
# mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/mbpp/"
# $QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/mbpp/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/mbpp" "$REPO_PATH/scripts/tsubame/node_f/evaluate_english_mbpp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "true" "true" $APPTAINER_CACHE
