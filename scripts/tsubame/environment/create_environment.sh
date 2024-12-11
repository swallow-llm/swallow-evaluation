REPO_PATH="/gs/fs/tga-okazaki/shimada/vllm/jalm-evaluation-private"
PIP_CACHE="/gs/bs/tga-okazaki/shimada/HF_HOME/pipcache"
QSUB_CMD="qsub -g tga-okazaki"

#$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/bigcode.out" "$REPO_PATH/scripts/tsubame/environment/bigcode.sh" $REPO_PATH $PIP_CACHE
#$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/fastchat.out" "$REPO_PATH/scripts/tsubame/environment/fastchat.sh" $REPO_PATH $PIP_CACHE
#$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/llm-jp-eval.out" "$REPO_PATH/scripts/tsubame/environment/llm-jp-eval.sh" $REPO_PATH $PIP_CACHE
#$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/lm-harness-en.out" "$REPO_PATH/scripts/tsubame/environment/lm-harness-en.sh" $REPO_PATH $PIP_CACHE
$QSUB_CMD -o "$REPO_PATH/scripts/tsubame/environment/logs/lm-harness-jp.out" "$REPO_PATH/scripts/tsubame/environment/lm-harness-jp.sh" $REPO_PATH $PIP_CACHE