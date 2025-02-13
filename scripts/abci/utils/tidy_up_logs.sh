#!/bin/bash
REPO_PATH=

# REPO_PATH が設定されているかチェック
if [ -z "$REPO_PATH" ]; then
  echo "Error: REPO_PATH environment variable is not set."
  exit 1
fi

# ユーザに確認
read -p "Are there any models currently being evaluated? (yes/no): " response
if [[ "$response" != "no" ]]; then
  echo "Aborting file move process. Please try again after all evaluations are done."
  exit 0
fi

# benchmark name -> dir name
declare -A benchmark_dir=(
  ["HarnessBBH"]="en/harness_en"
  ["HarnessGeneral"]="en/harness_en"
  ["HarnessGPQA"]="en/harness_en"
  ["HarnessMATH"]="en/harness_en"
  ["HarnessMMLU"]="en/harness_en"
  ["HumanEvalUnstriped"]="en/humaneval-unstripped"
  ["MBPP"]="en/mbpp"
  ["JHumanEvalUnstriped"]="ja/humaneval-unstripped"
  ["LLMJP"]="ja/llmjp"
  ["JMBPP"]="ja/mbpp"
  ["MGSM"]="ja/mgsm"
  ["MTBench"]="ja/ja_mt_bench"
  ["WMT20EnJa"]="ja/wmt20_en_ja"
  ["WMT20JaEn"]="ja/wmt20_ja_en"
  ["XLSum"]="ja/xlsum"
)

# ホームディレクトリ(~)にある対象ファイルを走査
# 拡張子が .o または .e のファイルを対象とする
for file in "$HOME"/.SE_*; do
  [ -e "$file" ] || continue

  # 例: .SE_meta-llama_Llama-3.2-3B-Instruct_MTBench.o72902 または
  #      .SE_meta-llama_Llama-3.2-3B-Instruct_MTBench.e72902
  filename=$(basename "$file")

  # 正規表現で各フィールドを抽出．
  # ここでは，拡張子部分を \.[oe]([0-9]+)$ として，.o と .e の両方にマッチさせる
  if [[ "$filename" =~ ^\.SE_([^_]+)_(.+)_([^_]+)\.[oe]([0-9]+)$ ]]; then
    owner="${BASH_REMATCH[1]}"
    model_name="${BASH_REMATCH[2]}"
    benchmark="${BASH_REMATCH[3]}"
    job_id="${BASH_REMATCH[4]}"

    # benchmark から対応する dir を取得
    dir="${benchmark_dir[$benchmark]}"
    if [-z "$dir" ]; then
        echo "Warning: No dir mapping found for benchmark '$benchmark'. Skipping file '$filename'."
      continue
    fi

    # 移動先ディレクトリを作成し，ファイルを移動
    dest="$REPO_PATH/results/${owner}/${model_name}/${dir}"
    if [ -d "$dest"]; then
      echo "Warning: No such dir named '$dest'. Skipping file '$filename'."
      continue
    fi

    echo "Moving '$file' to '$dest/'"
    mv "$file" "$dest/"
  else
    echo "Warning: File '$filename' does not match the expected pattern. Skipping."
  fi
done