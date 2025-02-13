GROUP_ID=gag51395

ROOT_PATH=$SWALLOW_EVAL_ROOT
PIP_CACHEDIR=$SWALLOW_EVAL_PIP_CACHEDIR
SINGULARITY_CACHEDIR=$SWALLOW_EVAL_SINGULARITY_CACHEDIR

mkdir -p logs

qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_bigcode -k oe -- "$ROOT_PATH/scripts/abci/environment/bigcode.sh" $ROOT_PATH $PIP_CACHEDIR $SINGULARITY_CACHEDIR
qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_fastchat -k oe -- "$ROOT_PATH/scripts/abci/environment/fastchat.sh" $ROOT_PATH $PIP_CACHEDIR
qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_llm-jp-eval -k oe -- "$ROOT_PATH/scripts/abci/environment/llm-jp-eval.sh" $ROOT_PATH $PIP_CACHEDIR
qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_harness-en -k oe -- "$ROOT_PATH/scripts/abci/environment/lm-harness-en.sh" $ROOT_PATH $PIP_CACHEDIR
qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_harness-jp -k oe -- "$ROOT_PATH/scripts/abci/environment/lm-harness-jp.sh" $ROOT_PATH $PIP_CACHEDIR
