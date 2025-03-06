# Swallowプロジェクト 大規模言語モデル 評価スクリプト Ver. 202411

* このリポジトリでは[Swallowプロジェクト](https://swallow-llm.github.io/index.ja.html)による大規模言語モデル；Swallowシリーズのリリースに用いた評価スクリプトを公開しています。
  再現実験などにご利用ください。
* 本文書では評価スクリプトの実行方法のみを説明します。評価方法や結果はSwallowプロジェクトの[評価ページ](https://swallow-llm.github.io/evaluation/about.ja.html)や論文発表を参照ください。
* 評価スクリプトは、基本的には [llm-jp-eval](https://github.com/llm-jp/llm-jp-eval) などの既存のLLM評価フレームワークを使用しています。
  この場をお借りしてフレームワーク開発者の皆様にお礼申し上げます。

## 注意事項

* **実行環境の違いにより、異なる評価結果になる場合があります。**
* 評価がうまくいかないなど問題があればIssueまでお願いします。

## 評価スクリプトが使用するLLM評価フレームワークおよびそれらのライセンス・変更点

### llm-jp-eval

* バージョン: [llm-jp-eval v1.3.0](https://github.com/llm-jp/llm-jp-eval/releases/tag/v1.3.0) [Han+, ANLP24]
* ライセンス: Copyright 2023 LLM-jp,  Apache License Version 2.0 ([LICENSE](llm-jp-eval/LICENSE))

#### 主な変更点
* モデルの応答を生成する際に貪欲デコーディングを強制するようにconfigを追加しました（[リンク](./llm-jp-eval/configs/config_no-sample.yaml))。
* JMMLUの結果をカテゴリごとに算出するスクリプトを追加しました ([リンク](./llm-jp-eval/scripts/jmmlu_statistics.py))。

### Language Model Evaluation Harness

* バージョン: [JP Language Model Evaluation Harness v0.4.2](https://github.com/EleutherAI/lm-evaluation-harness/releases/tag/v0.4.2)
* ライセンス: Copyright (c) 2020 EleutherAI, MIT License ([LICENSE](lm-evaluation-harness-en/LICENSE.md))

#### 主な変更点

* 数学のベンチマークである MATH の評価を行えるようにしました。
  * プロンプトは [minerva_math](https://github.com/EleutherAI/lm-evaluation-harness/tree/v0.4.2/lm_eval/tasks/minerva_math)の 4-shot CoT プロンプトを使用しています。
  * テストセットは Hendrycksら [Hendrycks+, NeurIPS21] によるオリジナルのtest split 5,000問ではなく、Lightmanらによる後続研究[Lightman+, ICLR24]で作成されたtest split 500問（いわゆる"MATH-500"）を使用しています。
  * 回答文生成は貪欲法で、停止条件に `I hope it is correct` を追加したほか、生成トークン数の上限を 1024 に変更しています。
  * 回答スパンの抽出方法は、デフォルト実装の `The final answer is(.*?).` だけでなく `\\boxed{}` も併用する方法に変更しました。
* 博士課程レベルの科学的知識や能力のベンチマークである GPQA の評価を行えるようにしました。
    * プロンプトは、Meta社によるLlama3.1評価再現用のリファレンス実装 [meta-llama/Llama-3.1-8B-Instruct-evals](https://huggingface.co/datasets/meta-llama/Llama-3.1-8B-Instruct-evals) の zero-shot CoT プロンプトを使用しています。
      またプロンプトと整合するように回答選択肢を抽出する正規表現を調整しました([リンク](./lm-evaluation-harness-en/lm_eval/tasks/gpqa/cot_zeroshot/gpqa_main_cot_zeroshot_meta_llama3_wo_chat.yaml))。  
    * テストセットは "main" subset の448問を使用しています。
    * 回答文生成は貪欲法で、生成トークン数の上限を 2048 にしています。

### JP Language Model Evaluation Harness
* バージョン: [Language Model Evaluation Harness v0.3.0](https://github.com/Stability-AI/lm-evaluation-harness) (commit #9b42d41) [Gao+, 22]
* ライセンス: Copyright (c) 2020 EleutherAI, MIT License ([LICENSE](lm-evaluation-harness-jp/LICENSE.md))

#### 主な変更点
* TER (Translation Error Rate) をブートストラップ統計量から除外しました。
* 評価結果のキャッシュの保存先を指定できるようにしました。
* huggingface tokenizerを読み込む際に`trust_remote_code`に渡す値を指定できるようにしました。

### FastChat
* バージョン: [FastChat](https://github.com/lm-sys/FastChat) (commit #e86e70d0)
* ライセンス: Apache License Version 2.0 ([LICENSE](fastchat/LICENSE))

#### 主な変更点
* 新しいモデルに対応するために、それぞれのモデルに対応するChatTemplateの追加をしました ([リンク](./fastchat/fastchat/conversation.py))。
* 一つの事例に対して複数回の応答文の生成と評価を行えるようにしました。
* OpenAIのAPIを呼び出す際のretryの処理を改善しました。
* 審判（judge）を gpt-4o-2024-08-06 に変更しました([リンク](./scripts/evaluate_ja_mt_bench.sh ))。
* 設問は Nejumi Leaderboard v3 の mtbench_ja_question:v4 ([リンク](https://wandb.ai/wandb-japan/llm-leaderboard/artifacts/)) を使用しています。  
  ただし coding/math/reasoning の模範解答は、mtbench_ja_referenceanswer:v2 ([リンク](https://wandb.ai/wandb-japan/llm-leaderboard/artifacts/dataset/mtbench_ja_referenceanswer/v2))をもとに、Swallowチームで独自に校閲・修正したものに変更しました([リンク](./fastchat/fastchat/llm_judge/data/japanese_mt_bench/reference_answer/gpt-4o-2024-08-06.jsonl))。  
* 応答文の日本語文字率を計算する関数を追加しました([リンク](./fastchat/fastchat/llm_judge/custom_utils.py))。

### Code Generation LM Evaluation Harness

* バージョン: [bigcode-evaluation-harness](https://github.com/bigcode-project/bigcode-evaluation-harness) (commit #0261c52)
* ライセンス: Apache License Version 2.0 ([LICENSE](bigcode-evaluation-harness/LICENSE))

#### 主な変更点
* JHumanEvalの評価を行えるようにしました ([リンク](./bigcode-evaluation-harness/bigcode_eval/tasks/humaneval.py))。
  * プロンプト末尾の改行 `n` を削除しない、いわゆる "unstripped" を使用しています。
* MBPP-Ja の評価を行えるようにしました ([リンク](./bigcode-evaluation-harness/bigcode_eval/tasks/mbpp_ja.py))。
  * テストセットは、llm-jp-eval v1.4.0 と同一です([MBPP-Ja](https://huggingface.co/datasets/llm-jp/mbpp-ja))。
    ただしMBPPの test split に合わせて task_id = 11--510 の設問のみを使用しています([リンク](./bigcode-evaluation-harness/bigcode_eval/tasks/mbpp_ja.py))。
* HumanEval / JHumanEval について、設問に対する回答率を計算する関数を追加しました ([リンク](./bigcode-evaluation-harness/bigcode_eval/custom_utils.py))。

## 評価フレームワークに追加したベンチマークのライセンス・変更点

### MATH (Language Model Evaluation Harnessで使用)
* バージョン: [HuggingFaceH4/MATH-500](https://huggingface.co/datasets/HuggingFaceH4/MATH-500), [オリジナル](https://github.com/hendrycks/math/tree/main)
* ライセンス: Copyright (c) 2021 Dan Hendrycks , MIT License ([LICENSE](https://github.com/hendrycks/math/blob/main/LICENSE))
* 主な変更点: なし

### GPQA (Language Model Evaluation Harnessで使用)
* バージョン: [idavidrein/gpqa](https://github.com/idavidrein/gpqa/tree/main)
* ライセンス: Copyright (c) 2022 I. David Rein, MIT License ([LICENSE](https://github.com/idavidrein/gpqa/blob/main/LICENSE))
* 主な変更点: なし

### JHumanEval (Code Generation LM Evaluation Harnessで使用)
* バージョン: [jhuman-eval](https://github.com/KuramitsuLab/jhuman-eval/tree/main)
* ライセンス: Copyright (c) 2023 Kimio Kuramitsu's Laboratory, MIT License ([LICENSE](https://github.com/KuramitsuLab/jhuman-eval/blob/main/LICENSE))
* 主な変更点: なし

### MBPP-Ja (Code Generation LM Evaluation Harnessで使用)
* 取得元: [llm-jp/mbpp-ja]([https://github.com/KuramitsuLab/jhuman-eval/tree/main](https://huggingface.co/datasets/llm-jp/mbpp-ja))
* ライセンス: Copyright (c) 2024 LLM-jp, CC BY 4.0 ([LICENSE](https://huggingface.co/datasets/llm-jp/mbpp-ja))
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

なお、以下の環境構築コードは、我々の計算環境においては動作検証をしておりますが、 \
利用される計算環境によってはバージョンが合わないことが考えられます。 \
その際は適宜適当なバージョンに置き換えてください。

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

## bigcode (J/HumanEval, MBPP, MBPP-Ja)

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
  `./scripts/re_evaluate_nli_task.py` に `llm-jp-eval` が出力した `output_eval.json` を渡してください。
  計算結果はjson形式でstdoutに出力されます。

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

* 多数の`output_eval.json`を一括で処理する場合は `./scripts/batch_re_evaluate_nli_task.sh` を実行してください。
  ただし find コマンドの対象パスをあなたのフォルダ構造に合わせて書き換えて使ってください。
  計算結果はndjson形式で `ja_nli_task_dataset_scores.json` に出力されます。
* ndjsonファイルをtsv形式に変換したい場合は jq を使うとよいでしょう。

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
bash scripts/evaluate_ja_{humaneval-unstripped,mbpp}.sh $MODEL_PATH true true
```

### 出力だけを行う場合

```bash
bash scripts/evaluate_ja_{humaneval-unstripped,mbpp}.sh $MODEL_PATH true false
```

### 評価だけを行う場合

```bash
bash scripts/evaluate_ja_{humaneval-unstripped,mbpp}.sh $MODEL_PATH false true
```

few-shot数: 0 (JHumanEval), 3 (MBPP Ja)

## fastchat(mt_bench)の評価の実行

```bash
bash scripts/evaluate_ja_mt_bench.sh $MODEL_PATH $GPU_NUM
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
  * 算術推論: GSM8K
  * 数学: MATH
  * 一般教養・学術知識: MMLU
  * 博士課程: GPQA

本フレームワークでは評価時間の削減（評価の並列化）のために以下のようにスクリプトを分けている。

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
bash scripts/evaluate_english_{humaneval-unstripped,mbpp}.sh $MODEL_PATH true true
```

### 出力だけを行う場合

```bash
bash scripts/evaluate_english_{humaneval-unstripped,mbpp}.sh $MODEL_PATH true false
```

### 評価だけを行う場合

```bash
bash scripts/evaluate_english_{humaneval-unstripped,mbpp}.sh $MODEL_PATH false true
```

## 結果の確認

- 全体の結果は`results/$MODEL_NAME/aggregated_result.json`に書き込まれます。
- 複数のモデルの結果を確認したい場合は、`tmp/model_list` ファイルを作成し、各モデル名を1行ずつ記入してください。その後、`scripts/show_results.py` を実行すると、複数モデルの結果を一覧表示できます。

