# TokyoTech-LLM 大規模言語モデル 評価スクリプト Ver. 202407
* TODO: 適切に変更
* このリポジトリでは[TokyoTech-LLM](https://tokyotech-llm.github.io/)による大規模言語モデル；Swallowシリーズのリリースおよび論文発表に用いた評価スクリプトを公開しています。
  再現実験などにご利用ください。
* 本文書では評価スクリプトの実行方法のみを説明します。評価方法や結果はSwallowシリーズのリリースや論文発表を参照ください。
* 評価スクリプトは，基本的には [llm-jp-eval](https://github.com/llm-jp/llm-jp-eval) などの既存のLLM評価フレームワークを使用しています。
  この場をお借りしてフレームワーク開発者の皆様にお礼申し上げます。

## 注意事項
* **実行環境の違いにより、異なる評価結果になる場合があります。**

## 評価スクリプトが適用されたモデルリリースおよび論文発表

### モデルリリース
* TODO: 書く

### 論文発表

```
@inproceedings{mizuki-iida-etal-2024-efficient-cpt,
  author = {水木 栄 and 飯田 大貴 and 藤井 一喜 and 中村 泰士 and Mengsay Loem and 大井 聖也 and 服部 翔 and 平井 翔太 and 横田 理央 and 岡崎 直観},
  title = {大規模言語モデルの日本語能力の効率的な強化: 継続事前学習における語彙拡張と対訳コーパスの活用},
  booktitle = {言語処理学会第30回年次大会 (NLP2024)},
  month = mar,
  year = {2024},
}

@inproceedings{okazaki-etal-2024-swallow-corpus,
  author = {岡崎 直観 and 服部 翔 and 平井 翔太 and 飯田 大貴 and 大井 聖也 and 藤井 一喜 and 中村 泰士 and Mengsay Loem and 横田 理央 and 水木 栄},
  title = {Swallowコーパス: 日本語大規模ウェブコーパス},
  booktitle = {言語処理学会第30回年次大会 (NLP2024)},
  month = mar,
  year = {2024},
}

@inproceedings{fuji-nakamura-etal-2024-swallow-llm,
  author = {藤井 一喜 and 中村 泰士 and Mengsay Loem and 飯田 大貴 and 大井 聖也 and 服部 翔 and 平井 翔太 and 水木 栄 and 横田 理央 and 岡崎 直観},
  title = {継続事前学習による日本語に強い大規模言語モデルの構築},
  booktitle = {言語処理学会第30回年次大会 (NLP2024)},
  month = mar,
  year = {2024},
}
```

## 評価スクリプトが使用するLLM評価フレームワークおよびそれらのライセンス・変更点

### llm-jp-eval

* バージョン: [llm-jp-eval v1.3.0](https://github.com/llm-jp/llm-jp-eval/releases/tag/v1.3.0) [Han+, ANLP24]
* ライセンス: Copyright 2023 LLM-jp,  Apache License Version 2.0 ([LICENSE](llm-jp-eval/LICENSE))
* 大きな変更点:
  * モデルの応答を生成する際に貪欲デコーディングを強制するようにconfigを追加しました（[リンク](./llm-jp-eval/configs/config_no-sample.yaml))。
  * JMMLUの結果をカテゴリごとに算出するスクリプトを追加しました ([リンク](./llm-jp-eval/scripts/jmmlu_statistics.py))。
  * 結果が保存されるファイル名に時刻が含まれないようにしました。

### Language Model Evaluation Harness

* バージョン: [JP Language Model Evaluation Harness v0.4.2](https://github.com/EleutherAI/lm-evaluation-harness/releases/tag/v0.4.2)
* ライセンス: Copyright (c) 2020 EleutherAI, MIT License ([LICENSE](lm-evaluation-harness-en/LICENSE.md))
* 大きな変更点: なし

### JP Language Model Evaluation Harness

* バージョン: [Language Model Evaluation Harness v0.3.0](https://github.com/Stability-AI/lm-evaluation-harness) (commit #9b42d41) [Gao+, 22]
* ライセンス: Copyright (c) 2020 EleutherAI, MIT License ([LICENSE](lm-evaluation-harness-jp/LICENSE.md))
* 大きな変更点:
  * TER (Translation Error Rate) をブートストラップ統計量から除外しました。
  * 評価結果のキャッシュの保存先を指定できるようにしました。
  * huggingface tokenizerを読み込む際に`trust_remote_code`に渡す値を指定できるようにしました。

### FastChat

* バージョン: [FastChat](https://github.com/lm-sys/FastChat) (commit #e86e70d0)
* ライセンス: Apache License Version 2.0 ([LICENSE](fastchat/LICENSE))
* 大きな変更点:
  * 新しいモデルに対応するために、それぞれのモデルに対応するChatTemplateの追加をしました ([リンク](./fastchat/fastchat/conversation.py))。
  * 一つの事例に対して複数回の応答文の生成と評価を行えるようにしました。
  * OpenAIのAPIを呼び出す際のretryの処理を改善しました。

### Code Generation LM Evaluation Harness

* バージョン: [bigcode-evaluation-harness](https://github.com/bigcode-project/bigcode-evaluation-harness) (commit #0261c52)
* ライセンス: Apache License Version 2.0 ([LICENSE](bigcode-evaluation-harness/LICENSE))
* 大きな変更点:
  * JHumanEvalの評価を行えるようにしました ([リンク](./bigcode-evaluation-harness/bigcode_eval/tasks/humaneval.py))。

#### JHumanEval (Code Generation LM Evaluation Harnessで使用)

* バージョン: [jhuman-eval](https://github.com/KuramitsuLab/jhuman-eval/tree/main)
* ライセンス: Copyright (c) 2023 Kimio Kuramitsu's Laboratory, MIT License ([LICENSE](https://github.com/KuramitsuLab/jhuman-eval/blob/main/LICENSE))
* 大きな変更点: なし
----

# 評価スクリプトの実行方法

## 準備：環境構築

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
pip install torch==2.1.0 --index-url https://download.pytorch.org/whl/cu118
pip install python-dotenv pandas
pip install -e ".[model_worker,llm_judge]"
```

torchのバージョンがcudaに合わない場合は、torchを入れ直してください。

`jalm-evaluation-private/.env`ファイルを作成し、AzureのAPIキーを入力する。

```txt
AZURE_OPENAI_KEY=...
AZURE_OPENAI_ENDPOINT=...
```

## 日本語の評価

* `llm-jp-eval` , `bigcode-evaluation-harness`, `lm-sys/FastChat`, および `JP LM Evaluation Harness` の一部を採用
  * 多肢選択・自然言語推論・質問応答・文書読解・数学
  * 生成タスク: 対話生成(mt_bench), XLSum, WMT20-en-ja, WMT20-ja-en, humaneval

### llm-jp-eval データセットの前処理

* [llm-jp-evalのREADME.md](https://github.com/llm-jp/llm-jp-eval/tree/main)に従って、データセットをダウンロードする

```bash
cd llm-jp-eval

python scripts/preprocess_dataset.py  \
--dataset-name all  \
--output-dir ./dataset

cd ../
```

### llm-jp-evalのタスクで評価

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

### xlsum（自動要約）のタスクで評価

```bash
bash scripts/evaluate_ja_xlsum.sh $MODEL_PATH
```

few-shot数: 1

### mgsm（数学）のタスクで評価

```bash
bash scripts/evaluate_ja_mgsm.sh $MODEL_PATH
```

few-shot数: 4

### WMT20（機械翻訳）のタスクで評価

```bash
bash scripts/evaluate_ja_wmt20_{enja,jaen}.sh $MODEL_PATH
```

few-shot数: 4

結果は
`results/${MODEL_PATH}/ja/${task_name}_${NUM_FEWSHOT}shot_${NUM_TESTCASE}cases/`
に保存される。

### JHumanevalのタスクで評価

* few-shot数: 0 (zero-shot)
* 評価を行うにはdockerイメージのビルドが必要

```bash
bash scripts/evaluate_ja_humaneval-unstripped.sh $MODEL_PATH true true
```

### MTBenchの評価

```bash
bash scripts/ja_mt_bench.sh $MODEL_PATH $GPU_NUM
```

* few-shot数: 0 (zero-shot)
* **GPT-4を呼び出すためAPI料金がかかるので注意が必要。**

## 英語の評価

### lm-evaluation-harness のタスクで評価

* `lm-evaluation-harness` を採用
  * 常識推論: HellaSwag, WinoGrande, OpenBookQA
  * 世界知識: TriviaQA
  * 文書読解: SQuAD
  * 数学: GSM8K
  * 一般教養・学術知識: MMLU
  * LLMにとって難しいタスクのコレクション: BBH (BIG-Bench-Hard)

fewshot数は

* MMLU: 5
* BBH: 3
* その他(HellaSwag, WinoGrande, OpenBookQA, TriviaQA, SQuAD, GSM8K): 4

`jalm-evaluation-private/`にて

```bash
bash scripts/evaluate_english.sh $MODEL_PATH
```

### Humanevalのタスクで評価

* few-shot数: 0 (zero-shot)
* 評価を行うにはdockerイメージのビルドが必要

```bash
bash scripts/evaluate_english_humaneval-unstripped.sh $MODEL_PATH true true
```
