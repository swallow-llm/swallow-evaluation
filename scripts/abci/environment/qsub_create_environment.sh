REPO_PATH="/home/acg16653re/github/jalm-evaluation-private_2412_update-saito_dev_abci"
PIP_CACHEDIR="/home/acg16653re/.cache/pip"
SINGULARITY_CACHEDIR="/home/acg16653re/.cache/singularity"
GROUP_ID="gag51395"
mkdir -p logs

qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_bigcode -k oe -- "$REPO_PATH/scripts/abci/environment/bigcode.sh" $REPO_PATH $PIP_CACHEDIR $SINGULARITY_CACHEDIR
qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_fastchat -k oe -- "$REPO_PATH/scripts/abci/environment/fastchat.sh" $REPO_PATH $PIP_CACHEDIR
