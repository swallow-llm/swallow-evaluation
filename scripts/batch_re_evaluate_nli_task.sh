#!/bin/bash

# 出力ファイルの初期化
output_file="ja_nli_task_dataset_scores.json"

echo "results will be saved to: ${output_file}"
echo -n "" > $output_file

# findコマンドでJSONファイルを検索し、それぞれに対してPythonスクリプトを実行
find . -type f -path '*/ja/llmjp_4shot_-1cases/output_eval.json' | while read json_file; do
    echo "processing: ${json_file}"
    # Pythonスクリプトを実行し、結果を一時ファイルに保存
    python re_evaluate_nli_task.py --input="$json_file" >> $output_file
done;

echo "finished. good-bye."
