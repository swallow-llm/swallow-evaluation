#!/bin/bash

# スクリプトのあるディレクトリに移動
cd "$(dirname "$0")"

# 現在のジョブの状態を取得して一時ファイルに保存
qstat_output=$(qstat -u $USER)

# qstatの返り値が空文字、すなわちキューが何もない時は終了
if [ -z "$qstat_output" ]; then
  exit 0
fi

# qstatの返り値を一時ファイルに保存
echo "$qstat_output" > current_qstat.out

# 一時ファイルを解析してジョブIDと状態を取得
current_jobs=$(awk 'NR>2 {print $1, $5}' current_qstat.out)

# 結果を格納する変数を初期化
results=""
declare -A current_job_map

# 各ジョブについて情報を取得
while read -r job_id state; do
  job_info=$(qstat -j "$job_id")
  task_kind=$(echo "$job_info" | grep job_name | awk '{print $2}' | sed -e 's:evaluate_::' -e 's:.sh::')
  model_name=$(echo "$job_info" | grep job_args | sed 's:.*/::' | sed 's/,.*//')
  node_kind=$(echo "$job_info" | grep ar_ids | awk '{print $2}')
  slots=$(echo "$job_info" | grep parallel | awk '{print $5}')
  
  if [ -z "$node_kind" ]; then
    node_kind="normal"
  fi

  # タスク名とモデル名が空でない場合のみ結果を蓄積
  if [[ -n "$task_kind" && -n "$model_name" ]]; then
    results+="$job_id\t$state\t$node_kind\t$slots\t$task_kind\t$model_name\n"
    current_job_map["$job_id"]="$state $node_kind $slots $task_kind $model_name"
  fi
done <<< "$current_jobs"

# 出力のヘッダー
printf "%-10s %-8s %-10s %-8s %-50s %-100s\n" "job_ID" "state" "node" "slots" "task" "model name"
echo -e "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

# 前回のジョブの状態を読み込む
if [ -f qstat_history.out ]; then
  old_jobs=$(cat qstat_history.out)

  # 前回のジョブIDが現在のジョブIDにない場合は終了したとみなす
  echo "$old_jobs" | while read -r old_job_id old_state old_node_kind old_slots old_task_kind old_model_name; do
    if [[ -z "${current_job_map[$old_job_id]}" ]]; then
      printf "%-10s %-8s %-10s %-8s %-50s %-100s\n" "$old_job_id" "done" "$old_node_kind" "$old_slots" "$old_task_kind" "$old_model_name"
    fi
  done
fi

# 現在のジョブ情報を表示
echo -e "$results" | while read -r job_id state node_kind slots task_kind model_name; do
  if [[ -n "$job_id" ]]; then
    printf "%-10s %-8s %-10s %-8s %-50s %-100s\n" "$job_id" "$state" "$node_kind" "$slots" "$task_kind" "$model_name"
  fi
done

# 現在のジョブ情報を保存
echo -e "$results" > qstat_history.out

# 一時ファイルを削除
rm current_qstat.out