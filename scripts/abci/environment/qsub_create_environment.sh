REPO_PATH="/home/acb11709gz/jalm-evaluation-private"
GROUP_ID="gag51395"
mkdir -p logs

qsub -g $GROUP_ID -o "$REPO_PATH/scripts/abci/environment/logs/" -e "$REPO_PATH/scripts/abci/environment/logs/" "$REPO_PATH/scripts/abci/environment/llm-jp-eval.sh" $REPO_PATH
qsub -g $GROUP_ID -o "$REPO_PATH/scripts/abci/environment/logs/" -e "$REPO_PATH/scripts/abci/environment/logs/" "$REPO_PATH/scripts/abci/environment/lm-harness-jp.sh" $REPO_PATH
qsub -g $GROUP_ID -o "$REPO_PATH/scripts/abci/environment/logs/" -e "$REPO_PATH/scripts/abci/environment/logs/" "$REPO_PATH/scripts/abci/environment/lm-harness-en.sh" $REPO_PATH
qsub -g $GROUP_ID -o "$REPO_PATH/scripts/abci/environment/logs/" -e "$REPO_PATH/scripts/abci/environment/logs/" "$REPO_PATH/scripts/abci/environment/bigcode.sh" $REPO_PATH
qsub -g $GROUP_ID -o "$REPO_PATH/scripts/abci/environment/logs/" -e "$REPO_PATH/scripts/abci/environment/logs/" "$REPO_PATH/scripts/abci/environment/fastchat.sh" $REPO_PATH