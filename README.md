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
cd llm_jp_eval
pip install .
```
`jalm-evaluation/`にて
```
source .venv_harness_jp/bin/activate
cd lm-evaluation-harness-jp
pip install -e ".[ja]"
```
`jalm-evaluation/`にて
```
source .venv_harness_en/bin/activate
cd lm-evaluation-harness-en
pip install -e .
```

# 日本語の評価
* `llm-jp-eval` および `JP LM Evaluation Harness` の一部を採用
    * 多肢選択・自然言語推論・質問応答・文書読解・数学
    
`jalm-evaluation/`にて
```
bash scripts/evaluate_japanese.sh \
$MODEL_PATH \
$TOKENIZER_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```

結果は
`results/${MODEL_NAME}/ja/alltasks_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases/`
に保存される。

# 英語の評価
* `llm-evaluation-harness` を採用
    * 常識推論: HellaSwag, WinoGrande, OpenBookQA
    * 世界知識: TriviaQA
    * 文書読解: SQuAD
    * 数学: GSM8K
    * 生成タスク: XLSum, WMT20-en-ja, WMT20-ja-en

`jalm-evaluation/`にて
```
bash scripts/evaluate_english.sh \
$MODEL_PATH \
$NUM_FEWSHOT \
$NUM_TESTCASE
```
    