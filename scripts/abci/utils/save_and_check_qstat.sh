#!/bin/bash

# スクリプトのあるディレクトリに移動
cd "$(dirname "$0")"

# 現在のジョブ情報を取得（-f で詳細情報）
qstat_output=$(qstat -f)
old_jobs=$(cat .qstat_history.out 2>/dev/null)

# どちらも空の場合は終了
if [[ -z "$qstat_output" && -z "$old_jobs" ]]; then
  exit 0
fi

# qstat の出力を一時ファイルに保存
echo "$qstat_output" > .current_qstat.out

results=""
declare -A current_job_map

# awk で RS (レコードセパレータ) を空文字にしてジョブブロックを抽出し，
# 各ブロックの末尾に null 文字 ("\0") を付与することで，
# while read -d '' で null 区切りの入力として扱えるようにする
while IFS= read -r -d '' job_block; do
    # PBS の出力は、値が長い場合に改行＋インデントされるので，まず継続行を結合
    job_block=$(echo "$job_block" | sed -e ':a;N;$!ba;s/\n[[:space:]]\+/ /g')

    # 各項目を抽出（先頭の空白を許容）
    job_id=$(echo "$job_block" | sed -n 's/^[[:space:]]*Job Id:[[:space:]]*\([^[:space:]]*\).*/\1/p')
    state=$(echo "$job_block" | sed -n 's/.*job_state[[:space:]]*=[[:space:]]*\([^[:space:]]*\).*/\1/p')
    job_name=$(echo "$job_block" | sed -n 's/.*Job_Name[[:space:]]*=[[:space:]]*\([^[:space:]]*\).*/\1/p')

    # task_kind として、不要な接頭辞 (.SE_) や拡張子 (.sh) を除去
    task_kind=$(echo "$job_name" | sed -e 's/^\.SE_[^_]*_[^_]*_//' -e 's/\.sh$//')
    model_name=$(echo "$job_name" | sed -e 's/^\.SE_//' -e 's/_[^_]*$//')

    node_kind=$(echo "$job_block" | sed -n 's/.*Account_Name[[:space:]]*=[[:space:]]*\([^[:space:]]*\).*/\1/p' | sed -e 's/:.*//')

    # task_kind と model_name が取得できた場合のみ結果に追加
    if [[ -n "$task_kind" && -n "$model_name" ]]; then
       results+="${job_id}\t${state}\t${node_kind}\t${task_kind}\t${model_name}\n"
       current_job_map["$job_id"]="${state} ${node_kind} ${task_kind} ${model_name}"
    fi

done < <(awk -v RS='' '{print $0 "\0"}' .current_qstat.out)

# 出力ヘッダーの表示（不要な情報を削除した形）
printf "%-15s %-8s %-8s %-20s %-100s\n" "job_ID" "state" "node" "task" "model name"
printf '%*s\n' 131 '' | tr ' ' '-'

# 前回の情報（old_jobs）と比較し、現在存在しないジョブは「done」として表示
if [ -n "$old_jobs" ]; then
  while read -r old_job_id old_state old_node_kind old_task_kind old_model_name; do
    if [[ -z "${current_job_map[$old_job_id]}" ]]; then
      printf "%-15s %-8s %-8s %-20s %-100s\n" "$old_job_id" "done" "$old_node_kind" "$old_task_kind" "$old_model_name"
    fi
  done < <(echo -e "$old_jobs")
fi

# 現在のジョブ情報を表示
echo -e "$results" | while IFS=$'\t' read -r job_id state node_kind task_kind model_name; do
  if [[ -n "$job_id" ]]; then
    printf "%-15s %-8s %-8s %-35s %-100s\n" "$job_id" "$state" "$node_kind" "$task_kind" "$model_name"
  fi
done

# 現在のジョブ情報を保存（次回比較用）
echo -e "$results" > .qstat_history.out

# 一時ファイルを削除
rm .current_qstat.out