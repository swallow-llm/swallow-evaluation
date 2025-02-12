REPO_PATH=$SWALLOW_EVAL_ROOT
PIP_CACHEDIR=$SWALLOW_EVAL_PIP_CACHE
SINGULARITY_CACHEDIR=$SWALLOW_EVAL_SINGULARITY_CACHE
GROUP_ID=gag51395
mkdir -p logs

qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_bigcode -k oe -- "$REPO_PATH/scripts/abci/environment/bigcode.sh" $REPO_PATH $PIP_CACHEDIR $SINGULARITY_CACHEDIR
qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_fastchat -k oe -- "$REPO_PATH/scripts/abci/environment/fastchat.sh" $REPO_PATH $PIP_CACHEDIR
qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_llm-jp-eval -k oe -- "$REPO_PATH/scripts/abci/environment/llm-jp-eval.sh" $REPO_PATH $PIP_CACHEDIR
qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_harness-en -k oe -- "$REPO_PATH/scripts/abci/environment/lm-harness-en.sh" $REPO_PATH $PIP_CACHEDIR
qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_harness-jp -k oe -- "$REPO_PATH/scripts/abci/environment/lm-harness-jp.sh" $REPO_PATH $PIP_CACHEDIR
