# Swallowプロジェクト 大規模言語モデル 評価スクリプト Ver. 202503

* このリポジトリでは[Swallowプロジェクト](https://swallow-llm.github.io/index.ja.html)による大規模言語モデル；Swallowシリーズのリリースに用いた評価スクリプトを公開しています。
  再現実験などにご利用ください。
* 本文書では評価スクリプトの実行方法のみを説明します。評価方法や結果はSwallowプロジェクトの[評価ページ](https://swallow-llm.github.io/evaluation/about.ja.html)や論文発表を参照ください。
* 評価スクリプトは，基本的には [llm-jp-eval](https://github.com/llm-jp/llm-jp-eval) などの既存のLLM評価フレームワークを使用しています。
  この場をお借りしてフレームワーク開発者の皆様にお礼申し上げます。

## 注意事項

* **実行環境の違いにより、異なる評価結果になる場合があります。**
* 評価がうまくいかないなど問題があればIssueまでお願いします。

## 評価スクリプトが使用するLLM評価フレームワークおよびそれらのライセンス・変更点

### llm-jp-eval

* バージョン: [llm-jp-eval v1.3.0](https://github.com/llm-jp/llm-jp-eval/releases/tag/v1.3.0) [Han+, ANLP24]
* ライセンス: Copyright 2023 LLM-jp,  Apache License Version 2.0 ([LICENSE](llm-jp-eval/LICENSE))
* 主な変更点:
  * なし

### Language Model Evaluation Harness

* バージョン: [JP Language Model Evaluation Harness v0.4.2](https://github.com/EleutherAI/lm-evaluation-harness/releases/tag/v0.4.2)
* ライセンス: Copyright (c) 2020 EleutherAI, MIT License ([LICENSE](lm-evaluation-harness-en/LICENSE.md))
* 主な変更点: 
  * SQuAD v2.0 を「回答不能」も考慮した評価指標に変更しました。([リンク](./lm-evaluation-harness-en/lm_eval/tasks/squadv2/task.py))
  * 博士課程レベルの教養ベンチマークである GPQA の評価を行えるようにしました。([リンク](./lm-evaluation-harness-en/lm_eval/tasks/gpqa/README.md))
  * 数学のベンチマークである MATH の評価を行えるようにしました。([リンク](./lm-evaluation-harness-en/lm_eval/tasks/math_500/README.md))

### JP Language Model Evaluation Harness

* バージョン: [Language Model Evaluation Harness v0.3.0](https://github.com/Stability-AI/lm-evaluation-harness) (commit #9b42d41) [Gao+, 22]
* ライセンス: Copyright (c) 2020 EleutherAI, MIT License ([LICENSE](lm-evaluation-harness-jp/LICENSE.md))
* 主な変更点:
  * なし

### FastChat

* バージョン: [FastChat](https://github.com/lm-sys/FastChat) (commit #e86e70d0)
* ライセンス: Apache License Version 2.0 ([LICENSE](fastchat/LICENSE))
* 主な変更点:
  * MT-Benchに関して、以下 4 点の変更を行いました。
    * 審判（judge）を gpt-4o-2024-08-06 に変更しました([リンク](./scripts/evaluate_ja_mt_bench.sh ))。
    * 設問をNejumi最新版に更新しました([リンク](https://wandb.ai/wandb-japan/llm-leaderboard/artifacts/ ))。
    * 模範解答は、 mtbench_ja_referenceanswer:v2 を使用し、Swallowチームで独自に校閲したものに変更しました([リンク](./fastchat/fastchat/llm_judge/data/japanese_mt_bench/reference_answer/gpt-4o-2024-08-06.jsonl ))。
    * MT-Bench補助評価指標である"応答文の日本語文字率" を、Markdown修飾を除外したものに変更しました([リンク](./fastchat/fastchat/llm_judge/custom_utils.py ))。

### Code Generation LM Evaluation Harness

* バージョン: [bigcode-evaluation-harness](https://github.com/bigcode-project/bigcode-evaluation-harness) (commit #0261c52)
* ライセンス: Apache License Version 2.0 ([LICENSE](bigcode-evaluation-harness/LICENSE))
* 主な変更点:
  * MBPP の評価を行えるようにしました ([リンク](./bigcode-evaluation-harness/bigcode_eval/tasks/mbpp.py))。
  * MBPP-Ja の評価を行えるようにしました ([リンク](./bigcode-evaluation-harness/bigcode_eval/tasks/mbpp_ja.py))。
    * MBPP-Ja は、 llm-jp-eval v1.4.0 と同じものです([MBPP-Ja](https://huggingface.co/datasets/llm-jp/mbpp-ja))。 ただし英語MBPPの test split に合わせて task_id = 11--510 の設問のみを使用しています。([リンク](./bigcode-evaluation-harness/bigcode_eval/tasks/mbpp_ja.py))

#### JHumanEval (Code Generation LM Evaluation Harnessで使用)

* バージョン: [jhuman-eval](https://github.com/KuramitsuLab/jhuman-eval/tree/main)
* ライセンス: Copyright (c) 2023 Kimio Kuramitsu's Laboratory, MIT License ([LICENSE](https://github.com/KuramitsuLab/jhuman-eval/blob/main/LICENSE))
* 主な変更点: なし



# FAQ
[こちら](MEMO.md)

# 準備：環境構築

各フレームワークに対し、別々の仮想環境を用意することを推奨します。

Pythonのバージョンは3.10.14を使ってください。

```bash
python -m venv .venv_llm_jp_eval
python -m venv .venv_harness_jp
python -m venv .venv_harness_en
python -m venv .venv_bigcode
python -m venv .venv_fastchat
```

なお，以下の環境構築コードは，我々の計算環境においては動作検証をしておりますが， \
利用される計算環境によってはバージョンが合わないことが考えられます． \
その際は適宜適当なバージョンに置き換えてください．

## llm-jp-eval (llmjp)

`jalm-evaluation-private/`にて

```bash
source .venv_llm_jp_eval/bin/activate
cd llm-jp-eval
pip install --upgrade pip
pip install -e .
pip install protobuf sentencepiece
pip install 'accelerate>=0.26.0'
pip install datasets==2.21.0
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121
```

## harness-jp (MGSM, XL-SUM, WMT20-EN-JA, WMT20-JA-EN)

`jalm-evaluation-private/`にて

```bash
source .venv_harness_jp/bin/activate
cd lm-evaluation-harness-jp
pip install --upgrade pip
pip install -e ".[ja]"
pip install sacrebleu sentencepiece protobuf nagisa
pip install 'accelerate>=0.26.0'
pip install datasets==2.21.0
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121
```

## harness-en (BBH, MATH, MMLU, GPQA, General(TriviaQA, GSM8K, OpenBookQA, Hellaswag, XWINO, SQuAD2))

`jalm-evaluation-private/`にて

```bash
source .venv_harness_en/bin/activate
cd lm-evaluation-harness-en
pip install --upgrade pip
pip install -e  ".[math]"
pip install sentencepiece==0.2.0 protobuf==5.28.3 transformers==4.46.2
pip install 'accelerate>=0.26.0'
pip install datasets==2.21.0
pip install vllm==v0.6.3.post1
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121
```

## bigcode (J/HumanEval, JA/EN MBPP)

1. `jalm-evaluation-private/`にて 
```bash
source .venv_bigcode/bin/activate
cd bigcode-evaluation-harness
pip install --upgrade pip
pip install -e .
pip install sentencepiece==0.2.0 protobuf==5.28.3 transformers==4.46.2
pip install 'accelerate>=0.26.0'
pip install datasets==2.21.0
pip install vllm==v0.6.3.post1
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121
```

2. bigcode-evaluation-harnessの[指示](https://github.com/bigcode-project/bigcode-evaluation-harness/tree/main?tab=readme-ov-file#docker-containers)に従ってdockerイメージをビルドする。

## fastchat (MT-Bench)

`jalm-evaluation-private/`にて

```bash
source .venv_fastchat/bin/activate
cd fastchat
pip install --upgrade pip
pip install python-dotenv pandas
pip install -e ".[model_worker,llm_judge]"
pip install vllm==v0.6.3.post1
pip install torch==2.4.0 --index-url https://download.pytorch.org/whl/cu121
pip install markdown beautifulsoup4
```

モデルの生成文を gpt-4o-2024-08-06 を用いて評価する（LLM-as-a-judge）ので \
`jalm-evaluation-private/.env`ファイルを作成し、OpenAIのAPIキーを入力する。

```txt
OPENAI_API_KEY=...
```

# 日本語の評価

* `llm-jp-eval` , `bigcode-evaluation-harness`, `lm-sys/FastChat`, および `JP LM Evaluation Harness` の一部を採用
  * 多肢選択・自然言語推論・質問応答・文書読解・数学
  * 生成タスク: 対話生成(mt_bench), XLSum, WMT20-en-ja, WMT20-ja-en, humaneval

## llm-jp-eval データセットの前処理

[llm-jp-evalのREADME.md](https://github.com/llm-jp/llm-jp-eval/tree/main)に従い、以下のコマンドを実行してデータセットをダウンロードする

```bash
source .venv_llm_jp_eval/bin/activate
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
bash scripts/evaluate_ja_llmjp.sh $MODEL_PATH
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

## JHumaneval/MBPP Jaのタスクで評価

* データは[JHumanEval](https://github.com/KuramitsuLab/jhuman-eval)を使用。
* few-shot数: 10
* 評価を行うにはdockerイメージのビルドが必要

### 出力と評価を同時に行う場合

```bash
bash scripts/evaluate_ja_{humaneval,mbpp}.sh $MODEL_PATH true true
```

### 出力だけを行う場合

```bash
bash scripts/evaluate_ja_{humaneval,mbpp}.sh $MODEL_PATH true false
```

### 評価だけを行う場合

```bash
bash scripts/evaluate_ja_{humaneval,mbpp}.sh $MODEL_PATH false true
```

few-shot数: 0 (JHumanEval), 3 (MBPP Ja)

## fastchat(mt_bench)の評価の実行

```bash
bash scripts/ja_mt_bench.sh $MODEL_PATH $GPU_NUM
```

few-shot数: 0 (zero-shot)

結果は
`results/${MODEL_PATH}/ja/ja_mt_bench/`
に保存される。

**GPT-4を呼び出すためAPI料金がかかるので注意が必要。**

<br> <br>

# 英語の評価

## `llm-evaluation-harness`での評価

* `llm-evaluation-harness` を採用
  * 常識推論: HellaSwag, WinoGrande, OpenBookQA
  * 世界知識: TriviaQA
  * 文書読解: SQuAD2
  * 数学: GSM8K, MATH
  * 一般教養・学術知識: MMLU
  * 博士課程: GPQA

本フレームワークでは評価時間の削減（評価の並列化）のために以下のようにスクリプトを分けている．

* `evaluate_english_general.sh` - TriviaQA, GSM8K, OpenBookQA, HellaSwag,WinoGrande, SQuAD2
* `evaluate_english_bbh.sh` - BBH
* `evaluate_english_gpqa.sh` - GPQA
* `evaluate_english_mmlu.sh` - MMLU

`jalm-evaluation-private/`にて

```bash
bash scripts/evaluate_english_{general,bbh,gpqa,mmlu}.sh $MODEL_PATH
```

## Humaneval, MBPP のタスクで評価

### 出力と評価を同時に行う場合

```bash
bash scripts/evaluate_english_{humaneval,mbpp}.sh $MODEL_PATH true true
```

### 出力だけを行う場合

```bash
bash scripts/evaluate_english_{humaneval,mbpp}.sh $MODEL_PATH true false
```

### 評価だけを行う場合

```bash
bash scripts/evaluate_english_{humaneval,mbpp}.sh $MODEL_PATH false true
```