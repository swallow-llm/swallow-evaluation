# 概要

英語の事前学習済み大規模言語モデルから継続学習されたモデルの評価。

評価軸：
* 日本語能力が改善されるか？
* 英語能力が維持されるか？

# 準備：環境構築
各フレームワークに対し、別々の仮想環境を用意することを推奨します

```
python -m venv .venv_llm_jp_eval
python -m venv .venv_harness_jp
python -m venv .venv_harness_en
python -m venv .venv_fastchat
```
`jalm-evaluation-private/`にて
```
source .venv_llm_jp_eval/bin/activate
cd llm-jp-eval
pip install .
pip install protobuf
pip install sentencepiece
```
`jalm-evaluation-private/`にて
```
source .venv_harness_jp/bin/activate
cd lm-evaluation-harness-jp
pip install -e ".[ja]"
pip install sacrebleu
pip install sentencepiece
pip install protobuf
```
`jalm-evaluation-private/`にて
```
source .venv_harness_en/bin/activate
cd lm-evaluation-harness-en
pip install -e .
pip install sentencepiece
pip install protobuf
```

`jalm-evaluation-private/`にて
```bash
source .venv_fastchat/bin/activate
cd fastchat
pip install -U pip
# 環境にあったtorchをinstall
pip install torch==2.1.0 --index-url https://download.pytorch.org/whl/cu118
pip install python-dotenv pandas
pip install -e ".[model_worker,llm_judge]"
```
`jalm-evaluation-private/.env`ファイルを作成し、AzureのAPIキーを入力する。
```
AZURE_OPENAI_KEY=...
AZURE_OPENAI_ENDPOINT=...
```

# 日本語の評価
* `llm-jp-eval`, `lm-sys/FastChat`,および `JP LM Evaluation Harness` の一部を採用
    * 多肢選択・自然言語推論・質問応答・文書読解・数学
    * 生成タスク: 対話生成(mt_bench), XLSum, WMT20-en-ja, WMT20-ja-en

## llm-jp-eval データセットの前処理
* まず[llm-jp-evalのREADME.md](https://github.com/llm-jp/llm-jp-eval/tree/main)に従って、データセットをダウンロードする  
* つぎに (a)公式設定 または (b)NLIタスクを日本語化 のいずれかの設定を選んで、前処理を実行する。  
  両者の違いは、NLIタスクのクラスラベルを(a)英語にするか または (b)日本語化するか である。  
  日本語に特化したLLM、特に指示チューニングしていないLLMの性能を評価する場合は (b)のほうが適切ではないかという説がある。  
  参考：[Stability AI 日本語大規模言語モデル「Japanese Stable LM Beta」シリーズをリリースしました](https://ja.stability.ai/blog/japanese-stable-lm-beta)

```
# (a)公式設定 の場合
前提と仮説の関係をentailment、contradiction、neutralの中から回答してください。

# (b)NLIタスクを日本語化 の場合
前提と仮説の関係を含意、矛盾、中立の中から回答してください。
```

```bash
cd llm-jp-eval

# (a)公式設定 の場合
python scripts/preprocess_dataset.py  \
--dataset-name all  \
--output-dir ./datasets

# (b)NLIタスクを日本語化 の場合
python scripts/preprocess_dataset.py  \
--dataset-name all  \
--output-dir ./datasets_nli_localize \
--localize_nli_verbalizer
```

## llm-jp-eval 評価の実行

`jalm-evaluation-private/`にて

llm-jp-evalのタスクで評価
```
bash scripts/evaluate_ja_llmjp.sh \
$MODEL_PATH \
$TOKENIZER_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
全テストケースで評価する場合は、NUM_TESTCASEを`-1`にしてください。

### NLIタスクのbalanced accuracyを計算する
* NLIタスクデータセット(`jamp,janli,jnli,jsem,jsick`)のbalanced accuracyを計算するには  
  `./scripts/re_evaluate_nli_task.py` に `llm-jp-eval` が出力した `output_eval.json` を渡してください．  
  計算結果はjson形式でstdoutに出力されます．  

```
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

```
# ヘッダ行の生成
head -n 1 {ndjsonファイル} | jq -r 'keys_unsorted | @tsv' > output.tsv
# 各行のデータの生成
cat {ndjsonファイル} | jq -r '[.[]] | @tsv' >> output.tsv
```

## xlsum（自動要約）のタスクで評価

```
bash scripts/evaluate_ja_xlsum.sh \
$MODEL_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
全テストケースで評価する場合は、`evaluate_ja_xlsum.sh`内の`--limit`を消してください。


## mgsm（数学）のタスクで評価

```
bash scripts/evaluate_ja_mgsm.sh \
$MODEL_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
全テストケースで評価する場合は、`evaluate_ja_mgsm.sh`内の`--limit`を消してください。

## WMT20（機械翻訳）のタスクで評価

```
bash scripts/evaluate_ja_wmt20_{enja,jaen}.sh \
$MODEL_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
全テストケースで評価する場合は、`evaluate_ja_wmt20_{enja,jaen}.sh`内の`--limit`を消してください。

結果は
`results/${MODEL_PATH}/ja/${task_name}_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases/`
に保存される。

## fastchat(mt_bench)の評価の実行
```bash
bash scripts/ja_mt_bench.sh $MODEL_PATH
```

結果は
`results/${MODEL_PATH}/ja/ja_mt_bench/`
に保存される。

# 英語の評価
* `llm-evaluation-harness` を採用
    * 常識推論: HellaSwag, WinoGrande, OpenBookQA
    * 世界知識: TriviaQA
    * 文書読解: SQuAD
    * 数学: GSM8K

`jalm-evaluation-private/`にて
```
bash scripts/evaluate_english.sh \
$MODEL_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
全テストケースで評価する場合は、`evaluate_english.sh`内の`--limit`を消してください。

# ABCI上
* `rt_AG.small=1` と `rt_AF=1` で全タスク全テストケースで評価するスクリプトは `scripts/abci/rt_{AGsmall,AF}/qsub_all.sh` です。
`jalm-evaluation-private/`にて
```
bash scripts/abci/rt_{AGsmall,AF}/qsub_all.sh $MODEL_NAME_OR_PATH
```
