#!/bin/bash

# スクリプトのあるディレクトリに移動
cd "$(dirname "$0")"

# 現在のジョブの状態を取得して一時ファイルに保存
qstat -u $USER > current_qstat.tmp

# 一時ファイルを解析してジョブIDと状態を取得
current_jobs=$(awk 'NR>2 {print $1, $5}' current_qstat.tmp)

# 結果を格納する変数を初期化
results=""
declare -A current_job_map

# 各ジョブについて情報を取得
while read -r job_id state; do
  task_kind=$(qstat -j "$job_id" | grep script_file | sed 's:.*/evaluate_::')
  model_name=$(qstat -j "$job_id" | grep job_args | sed 's:.*/::' | sed 's/,.*//')
  node_kind=$(qstat -j "$job_id" | grep ar_id | awk '{print $2}')
  if [ -z "$node_kind" ]; then
    node_kind="normal"
  fi

  # タスク名とモデル名が空でない場合のみ結果を蓄積
  if [[ -n "$task_kind" && -n "$model_name" ]]; then
    results+="$job_id\t$state\t$task_kind\t$model_name\t$node_kind\n"
    current_job_map["$job_id"]="$state $task_kind $model_name $node_kind"
  fi
done <<< "$current_jobs"

# 前回のジョブの状態を読み込む
if [ -f qstat_history.out ]; then
  old_jobs=$(cat qstat_history.out)

  # 前回のジョブIDが現在のジョブIDにない場合は終了したとみなす
  echo "$old_jobs" | while read -r old_job_id old_state old_task_kind old_model_name old_node_kind; do
    if [[ -z "${current_job_map[$old_job_id]}" ]]; then
      echo -e "$old_job_id was done.\tTask: $old_task_kind\tNode: $old_node_kind\tModel: $old_model_name"
    fi
  done
fi

# 現在のジョブ情報を表示
echo -e "$results" | while read -r job_id state task_kind model_name node_kind; do
  if [[ -n "$job_id" ]]; then
    echo -e "$job_id is currently $state.\tTask: $task_kind\tNode: $node_kind\tModel: $model_name"
  fi
done

# 現在のジョブ情報を保存
echo -e "$results" > qstat_history.out

# 一時ファイルを削除
rm current_qstat.tmp