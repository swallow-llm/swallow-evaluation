source ~/.bashrc

GROUP_ID="gag51395"

ROOT_PATH=$SWALLOW_EVAL_ROOT
HUGGINGFACE_CACHE=$SWALLOW_EVAL_HUGGINGFACE_CACHEDIR
MODEL_NAME_PATH=$1

# 環境変数がセットされているか確認
if [ -z "$SWALLOW_EVAL_ROOT" ]; then
  echo "Error: SWALLOW_EVAL_ROOT environment variable is not set."
  exit 1
fi

if [ -z "$SWALLOW_EVAL_HUGGINGFACE_CACHEDIR" ]; then
  echo "Error: SWALLOW_EVAL_HUGGINGFACE_CACHEDIR environment variable is not set."
  exit 1
fi

# Ensure MODEL_NAME_PATH is set.
if [ -z "$MODEL_NAME_PATH" ]; then
  echo "Error: MODEL_NAME_PATH is not set."
  exit 1
fi

# Japanese
# llmjp
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/ja/llmjp/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_LLMJP -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_ja_llmjp.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# wmt20
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/ja/wmt20_en_ja/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_WMT20EnJa -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_ja_wmt20_enja.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/ja/wmt20_ja_en/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_WMT20JaEn -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_ja_wmt20_jaen.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# xlsum
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/ja/xlsum/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_XLSum -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_ja_xlsum.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# mgsm
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/ja/mgsm/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MGSM -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_ja_mgsm.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# mt_bench
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/ja/ja_mt_bench/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MTBench -k oe --  "$ROOT_PATH/scripts/abci/rt_HF/evaluate_ja_mt_bench.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH 4

# jhumaneval-unstripped
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/ja/humaneval-unstripped/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_JHumanEvalUnstriped -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_ja_humaneval-unstripped.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# mbpp-ja
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/ja/mbpp/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_JMBPP -k oe --  "$ROOT_PATH/scripts/abci/rt_HF/evaluate_ja_mbpp.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH


# English
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/en/harness_en/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_HarnessEn -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_english_general.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MMLU -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_english_mmlu.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_BBH -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_english_bbh.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_Math -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_english_math.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_GPQA -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_english_gpqa.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# humaneval-unstripped
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/en/humaneval-unstripped/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_HumanEvalUnstriped -k oe -- "$ROOT_PATH/scripts/abci/rt_HF/evaluate_english_humaneval-unstripped.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH

# mbpp
mkdir -p "$ROOT_PATH/results/$MODEL_NAME_PATH/en/mbpp/"
qsub -P $GROUP_ID -q rt_HF -l select=1 -l walltime=24:00:00 -N .SE_${MODEL_NAME_PATH//\//_}_MBPP -k oe --  "$ROOT_PATH/scripts/abci/rt_HF/evaluate_english_mbpp.sh" $ROOT_PATH $HUGGINGFACE_CACHE $MODEL_NAME_PATH