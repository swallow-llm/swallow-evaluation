REPO_PATH="/home/acg16653re/github/jalm-evaluation-private_2412_update-saito_dev_abci"
PIP_CACHEDIR="/home/acg16653re/my_cache/pip_cache"
SINGULARITY_CACHEDIR="/home/acg16653re/my_cache/singularity_cache"
GROUP_ID="gag51395"
mkdir -p logs

qsub -P $GROUP_ID -q rt_HC -l select=1 -l walltime=01:00:00 -N .SE_crtenv_bigcode -k oe -- "$REPO_PATH/scripts/abci/environment/bigcode.sh" $REPO_PATH $PIP_CACHEDIR $SINGULARITY_CACHEDIR
