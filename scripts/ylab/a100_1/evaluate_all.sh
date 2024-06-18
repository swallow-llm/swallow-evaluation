#!/bin/bash

MODEL_NAME_PATH=$1

ybatch scripts/ylab/a100_1/evaluate_ja_llmjp.sh $MODEL_NAME_PATH $MODEL_NAME_PATH
ybatch scripts/ylab/a100_1/evaluate_ja_mgsm.sh $MODEL_NAME_PATH 
ybatch scripts/ylab/a100_1/evaluate_ja_wmt20_enja.sh $MODEL_NAME_PATH 
ybatch scripts/ylab/a100_1/evaluate_ja_wmt20_jaen.sh $MODEL_NAME_PATH 
ybatch scripts/ylab/a100_1/evaluate_ja_xlsum.sh $MODEL_NAME_PATH 
ybatch scripts/ylab/a100_1/evaluate_english.sh $MODEL_NAME_PATH 