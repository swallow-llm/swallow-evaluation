REPO_PATH="/gs/fs/tga-okazaki/path/to/your/repo"
HUGGINGFACE_CACHE="/gs/bs/tga-okazaki/path/to/your/huggingface_cache"
APPTAINER_CACHE="/gs/bs/tga-okazak/path/to/your/apptainer_cache"
QSUB_CMD="qsub -g tga-okazaki"
MODEL_NAME_PATH=$1

# Japanese
# mt_bench
#mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/"
#$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/" "$REPO_PATH/scripts/tsubame/node_q_vllm/evaluate_ja_mt_bench.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH 1

# jhumaneval-unstripped
#mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/"
#$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/" "$REPO_PATH/scripts/tsubame/node_q_vllm/evaluate_ja_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "true" "true" $APPTAINER_CACHE

# mbpp-ja
##mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp/"
#$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp" "$REPO_PATH/scripts/tsubame/node_q_vllm/evaluate_ja_mbpp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "true" "true" $APPTAINER_CACHE


# English
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/"
$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/tsubame/node_q_vllm/evaluate_english_general.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
#$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/tsubame/node_q_vllm/evaluate_english_mmlu.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/tsubame/node_q_vllm/evaluate_english_bbh.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
#$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en" "$REPO_PATH/scripts/tsubame/node_q_vllm/evaluate_english_math.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# humaneval-unstripped
#mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped/"
#$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped" "$REPO_PATH/scripts/tsubame/node_q_vllm/evaluate_english_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "true" "true" $APPTAINER_CACHE

# mbpp
#mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/mbpp/"
#$QSUB_CMD -o "$REPO_PATH/results/$MODEL_NAME_PATH/en/mbpp/" -e "$REPO_PATH/results/$MODEL_NAME_PATH/en/mbpp" "$REPO_PATH/scripts/tsubame/node_q_vllm/evaluate_english_mbpp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH "true" "true" $APPTAINER_CACHE
