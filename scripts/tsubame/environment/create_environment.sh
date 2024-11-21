REPO_PATH="/gs/fs/tga-okazaki/saito/jalm-evaluation-private"
HUGGINGFACE_CACHE="/gs/bs/tga-okazaki/saito/HF_HOME"
QSUB_CMD="qsub -g tga-okazaki"
MODEL_NAME_PATH=$1

$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/bigcode" "$REPO_PATH/scripts/tsubame/environment/bigcode.sh" $REPO_PATH
$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/fastchat" "$REPO_PATH/scripts/tsubame/environment/fastchat.sh" $REPO_PATH
$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/llm-jp-eval" "$REPO_PATH/scripts/tsubame/environment/llm-jp-eval.sh" $REPO_PATH
$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/lm-harness-en" "$REPO_PATH/scripts/tsubame/environment/lm-harness-en.sh" $REPO_PATH
$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/lm-harness-jp" "$REPO_PATH/scripts/tsubame/environment/lm-harness-jp.sh" $REPO_PATH