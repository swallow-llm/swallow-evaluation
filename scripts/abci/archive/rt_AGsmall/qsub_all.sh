#!/bash/bin

MODEL_NAME=$1

# Japanese tasks
qsub -g gcb50243 scripts/abci/rt_AGsmall/evaluate_ja_llmjp.sh $MODEL_NAME $MODEL_NAME 4 -1 &
qsub -g gcb50243 scripts/abci/rt_AGsmall/evaluate_ja_mgsm.sh $MODEL_NAME 4 &
qsub -g gcb50243 scripts/abci/rt_AGsmall/evaluate_ja_xlsum.sh $MODEL_NAME 4 &

# English tasks
qsub -g gcb50243 scripts/abci/rt_AGsmall/evaluate_english.sh $MODEL_NAME 8
