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
```
`jalm-evaluation/`にて
```
source .venv_llm_jp_eval/bin/activate
cd llm-jp-eval
pip install .
pip install protobuf
pip install sentencepiece
```
`jalm-evaluation/`にて
```
source .venv_harness_jp/bin/activate
cd lm-evaluation-harness-jp
pip install -e ".[ja]"
pip install sacrebleu
pip install sentencepiece
pip install protobuf
```
`jalm-evaluation/`にて
```
source .venv_harness_en/bin/activate
cd lm-evaluation-harness-en
pip install -e .
pip install sentencepiece
pip install protobuf
```

# 日本語の評価
* `llm-jp-eval` および `JP LM Evaluation Harness` の一部を採用
    * 多肢選択・自然言語推論・質問応答・文書読解・数学
    * 生成タスク: XLSum

* llm-jp-evalのREADME.mdに従って、データセットをダウンロードする
`llm-jp-eval/`にて
```bash
  poetry run python scripts/preprocess_dataset.py  \
  --dataset-name all  \
  --output-dir ./datasets
```
    
`jalm-evaluation/`にて

llm-jp-evalのタスクで評価
```
bash scripts/evaluate_ja_llmjp.sh \
$MODEL_PATH \
$TOKENIZER_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
全テストケースで評価する場合は、NUM_TESTCASEを`-1`にしてください。

xlsum（自動要約）のタスクで評価
```
bash scripts/evaluate_ja_xlsum.sh \
$MODEL_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
全テストケースで評価する場合は、`evaluate_ja_xlsum.sh`内の`--limit`を消してください。


mgsm（数学）のタスクで評価
```
bash scripts/evaluate_ja_mgsm.sh \
$MODEL_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
全テストケースで評価する場合は、`evaluate_ja_mgsm.sh`内の`--limit`を消してください。


結果は
`results/${MODEL_PATH}/ja/${task_name}_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases/`
に保存される。

# 英語の評価
* `llm-evaluation-harness` を採用
    * 常識推論: HellaSwag, WinoGrande, OpenBookQA
    * 世界知識: TriviaQA
    * 文書読解: SQuAD
    * 数学: GSM8K

`jalm-evaluation/`にて
```
bash scripts/evaluate_english.sh \
$MODEL_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
全テストケースで評価する場合は、`evaluate_english.sh`内の`--limit`を消してください。

