source ~/.bashrc

REPO_PATH=$SWALLOW_EVAL_ROOT
HUGGINGFACE_CACHE=$SWALLOW_EVAL_HUGGINGFACE_CACHE
GROUP_ID="gag51395"

MODEL_NAME_PATH=$1

# Japanese
# llmjp
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/llmjp/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_LLMJP -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_ja_llmjp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# wmt20
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_WMT20EnJa -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_ja_wmt20_enja.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_WMT20JaEn -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_ja_wmt20_jaen.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# xlsum
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/xlsum/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_XLSum -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_ja_xlsum.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# mgsm
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mgsm/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MGSM -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_ja_mgsm.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# mt_bench
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MTBench -k oe --  "$REPO_PATH/scripts/abci/rt_HG/evaluate_ja_mt_bench.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH 1

# jhumaneval-unstripped
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_JHumanEvalUnstriped -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_ja_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# jmbpp
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/ja/mbpp/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_JMBPP -k oe --  "$REPO_PATH/scripts/abci/rt_HG/evaluate_ja_mbpp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH


# English
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/harness_en/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_HarnessEn -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_english_general.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MMLU -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_english_mmlu.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_BBH -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_english_bbh.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_Math -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_english_math.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GPQA -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_english_gpqa.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# humaneval-unstripped
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_HumanEvalUnstriped -k oe -- "$REPO_PATH/scripts/abci/rt_HG/evaluate_english_humaneval-unstripped.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# mbpp
mkdir -p "$REPO_PATH/results/$MODEL_NAME_PATH/en/mbpp/"
qsub -P $GROUP_ID -q rt_HG -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MBPP -k oe --  "$REPO_PATH/scripts/abci/rt_HG/evaluate_english_mbpp.sh" $REPO_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH