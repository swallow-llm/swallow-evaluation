#!/bash/bin

MODEL_NAME=$1

# Japanese tasks
qsub -ar 26132 -g gaf51275 scripts/abci/rt_AF/evaluate_ja_llmjp.sh $MODEL_NAME $MODEL_NAME 4 -1 &
qsub -ar 26132 -g gaf51275 scripts/abci/rt_AF/evaluate_ja_mgsm.sh $MODEL_NAME 4 &
qsub -ar 26132 -g gaf51275 scripts/abci/rt_AF/evaluate_ja_xlsum.sh $MODEL_NAME 4 &

# English tasks
qsub -ar 26132 -g gaf51275 scripts/abci/rt_AF/evaluate_english.sh $MODEL_NAME 8
