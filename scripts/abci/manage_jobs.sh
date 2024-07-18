#!/bin/bash

# 引数としてタスク種別とオプションを受け取る
if [ -z "$1" ]; then
  echo "Usage: $0 <task_kind> [-d]"
  exit 1
fi

TASK_KIND="$1"
DELETE_JOBS=false

# オプションのチェック
if [ "$2" == "-d" ]; then
  DELETE_JOBS=true
fi

# 現在のジョブIDを取得
JOB_IDS=$(qstat | awk 'NR>2 {print $1}')

# 該当するジョブIDを格納するリスト
TARGET_JOBS=()

# 各ジョブIDについて調べる
for JOB_ID in $JOB_IDS; do
  # script_fileとTASK_KINDを含むジョブを見つける
  if qstat -j "$JOB_ID" | grep script_file | grep -q "$TASK_KIND"; then
    TARGET_JOBS+=("$JOB_ID")
  fi
done

# ジョブを削除するか、IDを表示する
if [ ${#TARGET_JOBS[@]} -eq 0 ]; then
  echo "No jobs found with task kind '$TASK_KIND'."
else
  if $DELETE_JOBS; then
    for JOB_ID in "${TARGET_JOBS[@]}"; do
      qdel "$JOB_ID"
    done
    echo "All jobs with task kind '$TASK_KIND' have been cancelled."
  else
    echo "Job IDs with task kind '$TASK_KIND':"
    for JOB_ID in "${TARGET_JOBS[@]}"; do
      echo "$JOB_ID"
    done
  fi
fi