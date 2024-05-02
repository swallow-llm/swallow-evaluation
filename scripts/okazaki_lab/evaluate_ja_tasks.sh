MODEL_NAME_PATH=$1
CUDA_VISIBLE_DEVICES=$2
GPU_NUM=$3

export CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES

bash scripts/evaluate_ja_humaneval.sh $MODEL_NAME_PATH true true
bash scripts/evaluate_ja_llmjp.sh $MODEL_NAME_PATH $MODEL_NAME_PATH
bash scripts/evaluate_ja_mgsm.sh $MODEL_NAME_PATH
bash scripts/evaluate_ja_mt_bench.sh $MODEL_NAME_PATH $GPU_NUM
bash scripts/evaluate_ja_wmt20_enja.sh $MODEL_NAME_PATH
bash scripts/evaluate_ja_wmt20_jaen.sh $MODEL_NAME_PATH
bash scripts/evaluate_ja_xlsum.sh $MODEL_NAME_PATH