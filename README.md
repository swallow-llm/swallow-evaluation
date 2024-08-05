# 概要

**バージョン**: 2024/08アップデート

英語の事前学習済み大規模言語モデルから継続学習されたモデルの評価。

評価軸：

* 日本語能力が改善されるか？
* 英語能力が維持されるか？

# 準備：環境構築

各フレームワークに対し、別々の仮想環境を用意することを推奨します。

Pythonのバージョンは3.9を使ってください。

```bash
python -m venv .venv_llm_jp_eval
python -m venv .venv_harness_jp
python -m venv .venv_harness_en
python -m venv .venv_bigcode
python -m venv .venv_fastchat
```

`jalm-evaluation-private/`にて

```bash
source .venv_llm_jp_eval/bin/activate
cd llm-jp-eval
pip install --upgrade pip
pip install -e .
pip install protobuf
pip install sentencepiece
```

torchのバージョンがcudaに合わない場合は、torchを入れ直してください。

`jalm-evaluation-private/`にて

```bash
source .venv_harness_jp/bin/activate
cd lm-evaluation-harness-jp
pip install --upgrade pip
pip install -e ".[ja]"
pip install sacrebleu
pip install sentencepiece
pip install protobuf
pip install nagisa
```

torchのバージョンがcudaに合わない場合は、torchを入れ直してください。

`jalm-evaluation-private/`にて

```bash
source .venv_harness_en/bin/activate
cd lm-evaluation-harness-en
pip install --upgrade pip
pip install -e .
pip install sentencepiece
pip install protobuf
```

torchのバージョンがcudaに合わない場合は、torchを入れ直してください。

`jalm-evaluation-private/`にて

```bash
source .venv_bigcode/bin/activate
cd bigcode-evaluation-harness
pip install --upgrade pip
pip install -e .
# For Llama
pip install sentencepiece
pip install protobuf
```

torchのバージョンがcudaに合わない場合は、torchを入れ直してください。

bigcode-evaluation-harnessの[指示](https://github.com/bigcode-project/bigcode-evaluation-harness/tree/main?tab=readme-ov-file#docker-containers)に従ってdockerイメージをビルドする。

`jalm-evaluation-private/`にて

```bash
source .venv_fastchat/bin/activate
cd fastchat
pip install --upgrade pip
pip install torch==2.1.0 --index-url https://download.pytorch.org/whl/cu121
pip install python-dotenv pandas
pip install -e ".[model_worker,llm_judge]"
pip install vllm
```

torchのバージョンがcudaに合わない場合は、torchを入れ直してください。

`jalm-evaluation-private/.env`ファイルを作成し、OpenAIのAPIキーを入力する。

```txt
OPENAI_API_KEY=...
```

# 日本語の評価

* `llm-jp-eval` , `bigcode-evaluation-harness`, `lm-sys/FastChat`, および `JP LM Evaluation Harness` の一部を採用
  * 多肢選択・自然言語推論・質問応答・文書読解・数学
  * 生成タスク: 対話生成(mt_bench), XLSum, WMT20-en-ja, WMT20-ja-en, humaneval

## llm-jp-eval データセットの前処理

* [llm-jp-evalのREADME.md](https://github.com/llm-jp/llm-jp-eval/tree/main)に従って、データセットをダウンロードする

```bash
cd llm-jp-eval

python scripts/preprocess_dataset.py  \
--dataset-name all  \
--output-dir ./dataset

cd ../
```

## llm-jp-eval 評価の実行

`jalm-evaluation-private/`にて

llm-jp-evalのタスクで評価

```bash
bash scripts/evaluate_ja_llmjp.sh \
$MODEL_PATH \
$TOKENIZER_PATH \
```

fewshot数は

* jmmlu: 5
* その他(jamp, janli, jcommonsenseqa, jnli, jsem, jsick, jsquad, jsts, niilc): 4


<details>
<summary> NLIタスクのbalanced accuracyを計算する</summary>

* NLIタスクデータセット(`jamp,janli,jnli,jsem,jsick`)のbalanced accuracyを計算するには
  `./scripts/re_evaluate_nli_task.py` に `llm-jp-eval` が出力した `output_eval.json` を渡してください．
  計算結果はjson形式でstdoutに出力されます．

```txt
python re_evaluate_nli_task.py --input="{output_eval.jsonのパス}" > {保存先のjsonファイルパス}

# 出力されるjsonの見本
{
  "input_path": "{入力したoutput_eval.jsonのパス}",
  "macro_accuracy": 0.38721748069591116, # accuracyのマクロ平均
  "macro_balanced_accuracy": 0.3709781734463517, # balanced accuracyのマクロ平均
  "jamp_balanced_accuracy": 0.33338203779466197, # 個別データセットのbalanced accuracy
  ...
}
```

* 多数の`output_eval.json`を一括で処理する場合は `./scripts/batch_re_evaluate_nli_task.sh` を実行してください．
  ただし find コマンドの対象パスをあなたのフォルダ構造に合わせて書き換えて使ってください．
  計算結果はndjson形式で `ja_nli_task_dataset_scores.json` に出力されます．
* ndjsonファイルをtsv形式に変換したい場合は jq を使うとよいでしょう．

```bash
# ヘッダ行の生成
head -n 1 {ndjsonファイル} | jq -r 'keys_unsorted | @tsv' > output.tsv
# 各行のデータの生成
cat {ndjsonファイル} | jq -r '[.[]] | @tsv' >> output.tsv
```
</details>

## xlsum（自動要約）のタスクで評価

```bash
bash scripts/evaluate_ja_xlsum.sh $MODEL_PATH
```

few-shot数: 1

## mgsm（数学）のタスクで評価

```bash
bash scripts/evaluate_ja_mgsm.sh $MODEL_PATH
```

few-shot数: 4

## WMT20（機械翻訳）のタスクで評価

```bash
bash scripts/evaluate_ja_wmt20_{enja,jaen}.sh $MODEL_PATH
```

few-shot数: 4

結果は
`results/${MODEL_PATH}/ja/${task_name}_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases/`
に保存される。

## Humanevalのタスクで評価

* データは[JHumanEval](https://github.com/KuramitsuLab/jhuman-eval)を使用。
* few-shot数: 10
* 評価を行うにはdockerイメージのビルドが必要

### 出力と評価を同時に行う場合

```bash
bash scripts/evaluate_ja_humaneval.sh $MODEL_PATH true true
```

### 出力だけを行う場合

```bash
bash scripts/evaluate_ja_humaneval.sh $MODEL_PATH true false
```

### 評価だけを行う場合

```bash
bash scripts/evaluate_ja_humaneval.sh $MODEL_PATH false true
```

#### Singularityを使う場合
```
cd bigcode-evaluation-harness
singularity pull docker://ghcr.io/bigcode-project/evaluation-harness:latest
```
でimageをpullしてください。
その後
```
singularity exec --bind jalm-evaluation-private/results/MODELPATH/ja/humaneval_10NUM_SAMPLES_1BATCH_SIZE/generation_jhumaneval.json:/app/generations_py.json evaluation-harness_latest.sif python3 main.py --model $MODELPATH --tasks jhumaneval --load_generations_path /app/generations_py.json --allow_code_execution --n_samples 10
```
で実行してください。

## mbpp_jaのタスクで評価

```bash
bash scripts/evaluate_ja_mbpp.sh $MODEL_PATH
```

* 評価部分は岡崎研内で採点APIを叩く仕様になっているので、横田研で使用する場合はdocker/singularityなどを使って評価してください。すみませんが未実装です。

## fastchat(mt_bench)の評価の実行

```bash
bash scripts/ja_mt_bench.sh $MODEL_PATH $GPU_NUM
```

few-shot数: 0 (zero-shot)

結果は
`results/${MODEL_PATH}/ja/ja_mt_bench/`
に保存される。

**GPT-4を呼び出すためAPI料金がかかるので注意が必要。**

# 英語の評価

## `llm-evaluation-harness`での評価

* `llm-evaluation-harness` を採用
  * 常識推論: HellaSwag, WinoGrande, OpenBookQA
  * 世界知識: TriviaQA
  * 文書読解: SQuAD
  * 数学: GSM8K
  * 一般教養・学術知識: MMLU

`jalm-evaluation-private/`にて

```bash
bash scripts/evaluate_english.sh $MODEL_PATH
```

## Humanevalのタスクで評価

### 出力と評価を同時に行う場合

```bash
bash scripts/evaluate_english_humaneval.sh $MODEL_PATH true true
```

### 出力だけを行う場合

```bash
bash scripts/evaluate_english_humaneval.sh $MODEL_PATH true false
```

### 評価だけを行う場合

```bash
bash scripts/evaluate_english_humaneval.sh $MODEL_PATH false true
```

#### Singularityを使う場合

```
cd bigcode-evaluation-harness
singularity pull docker://ghcr.io/bigcode-project/evaluation-harness:latest
```

でimageをpullしてください。
その後

```
singularity exec --bind jalm-evaluation-private/results/MODELPATH/en/humaneval_10NUM_SAMPLES_1BATCH_SIZE/generation_humaneval.json:/app/generations_py.json evaluation-harness_latest.sif python3 main.py --model $MODELPATH --tasks humaneval --load_generations_path /app/generations_py.json --allow_code_execution --n_samples 10
```

で実行してください。

## mbppのタスクで評価

```bash
bash scripts/evaluate_english_mbpp.sh $MODEL_PATH
```

* 評価部分は岡崎研内で採点APIを叩く仕様になっているので、横田研で使用する場合はdocker/singularityなどを使って評価してください。すみませんが未実装です。