REPO_PATH="/gs/bs/tga-okazaki/tga-ohi/jalm-evaluation-private"
GROUP_ID="tga-okazaki"
mkdir -p logs

qsub -g $GROUP_ID -o "$REPO_PATH/scripts/tsubame/environment/logs/" -e "$REPO_PATH/scripts/tsubame/environment/logs/" "$REPO_PATH/scripts/tsubame/environment/llm-jp-eval.sh" $REPO_PATH
qsub -g $GROUP_ID -o "$REPO_PATH/scripts/tsubame/environment/logs/" -e "$REPO_PATH/scripts/tsubame/environment/logs/" "$REPO_PATH/scripts/tsubame/environment/lm-harness-jp.sh" $REPO_PATH
qsub -g $GROUP_ID -o "$REPO_PATH/scripts/tsubame/environment/logs/" -e "$REPO_PATH/scripts/tsubame/environment/logs/" "$REPO_PATH/scripts/tsubame/environment/lm-harness-en.sh" $REPO_PATH
qsub -g $GROUP_ID -o "$REPO_PATH/scripts/tsubame/environment/logs/" -e "$REPO_PATH/scripts/tsubame/environment/logs/" "$REPO_PATH/scripts/tsubame/environment/bigcode.sh" $REPO_PATH
qsub -g $GROUP_ID -o "$REPO_PATH/scripts/tsubame/environment/logs/" -e "$REPO_PATH/scripts/tsubame/environment/logs/" "$REPO_PATH/scripts/tsubame/environment/fastchat.sh" $REPO_PATH