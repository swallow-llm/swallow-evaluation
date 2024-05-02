MODEL_NAME_PATH=$1
CUDA_VISIBLE_DEVICES=$2
GPU_NUM=$3

export CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES

bash scripts/evaluate_english_humaneval.sh $MODEL_NAME_PATH true true
bash scripts/evaluate_english.sh $MODEL_NAME_PATH