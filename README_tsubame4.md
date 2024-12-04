# 目次

- [概要](#概要)
- [初回準備](#初回準備)
    - [1. パスの編集](#1-パスの編集)
    - [2. 環境構築](#2-環境構築)
    - [うまく行かなかったら](#うまく行かなかったら)
- [評価の実行](#評価の実行)
    - [1. 評価するタスクの選択](#1-評価するタスクの選択)
    - [2. 評価スクリプトの実行](#2-評価スクリプトの実行)
    - [3. 評価状況の確認](#3-評価状況の確認)
    - [4. 結果の確認](#4-結果の確認)
- [評価の詳細](#評価の詳細)
    - [評価スクリプトとベンチマークの対応](#評価スクリプトとベンチマークの対応)
    - [評価結果の表とベンチマークの対応](#評価結果の表とベンチマークの対応)

<br>

# 概要

- **(2024/12/3  齋藤 追記) TSUBAME4.0用のスクリプト**
- TSUBAME4.0で評価を回す方法
- 内部資料なので公開する予定はない

<br>

# 初回準備

## 1. パスの編集

- `scripts/tsubame/environment/create_environment.sh`
- `scripts/tsubame/node_q/qsub_all.sh`
- `scripts/tsubame/node_f/qsub_all.sh`

**にハードコードされている以下の変数を自分の環境に合わせて編集する**

| 変数名 | 役割 |
| -- | -- |
| `REPO_PATH` | `jalm-evaluation-private`の絶対パス |
| `PIP_CACHE` | `pip install`のキャッシュを置く場所 (環境構築の際に使用) |
| `HUGGINGFACE_CACHE` | Huggingfaceのモデルの重みを置く場所 (評価の際に使用) |
| `APPTAINER_CACHE` | APPTAINERのキャッシュを置く場所 (J/HumanEvalやJA/EN MBPPの評価時に使用) |
| `QSUB_CMD`  | `qsub -g {グループ名}` `groups` コマンドで自分が使えるグループが確認できる | 

## 2. 環境構築

「A.1 パスの編集」で `scripts/tsubame/environment/create_environment.sh` のパスを正しくハードコードし直した上で、以下のコードをログインノードで実行。
```bash
bash scripts/tsubame/environment/create_environment.sh
```

これにより五つのジョブが流れ、以下の環境構築が行われる。
| ジョブ(環境)の名前 | 対応する評価タスク|
|--|--|
|`bigcode`|J/HumanEvalやJA/EN MBPP|
|`fastchat`| MT-Bench |
|`llm-jp-eval`| llmjp |
|`lm-harness-en`| BBH, Math, MMLU, General(TriviaQA, GSM8K, OpenBookQA, Hellaswag, XWINO, SQuAD2) |
|`lm-harness-jp` | MGSM, XL-SUM, WMT20-EN-JA, WMT20-JA-EN | の評価に使う環境の構築

なお、各環境を以下のように個別に構築することもできる。

`bigcode`の例：
```bash
REPO_PATH="/gs/fs/tga-okazaki/path/to/your/repo"
PIP_CACHE="/gs/bs/tga-okazaki/path/to/your/pipcache"
bash scripts/tsubame/environment/bigcode.sh
```

各環境の詳細(ライブラリの構成など)は `scripts/tsubame/environment/` 以下のコードを参照されたい。
また、実行時のログについては `scripts/tsubame/environment/logs/` 以下に出力されるので必要な際は確認されたい。

環境構築のジョブが走り切ったら `OPENAI_API_KEY` と `HF_TOKEN` を設定しておく。
```bash
cd /gs/fs/tga-okazaki/path/to/your/repo
echo OPENAI_API_KEY=sk-... > .env
echo HF_TOKEN=hf_... > .env
```

- [Qiita. "OpenAIのAPIキー取得方法|2024年7月最新版|料金体系や注意事項".](https://qiita.com/kurata04/items/a10bdc44cc0d1e62dad3)
- [Edge HUB. "Hugging Faceの使い方！アクセストークン作成からログインまで".](https://highreso.jp/edgehub/machinelearning/huggingfacetoken.html)


### うまく行かなかったら？
- torchとcudaのバージョンが合っているかを確かめる
    - [PyTorch. "Get Started".](https://pytorch.org/get-started/locally/)
    - [TSUBAME4.0利用の手引き. "4. ソフトウェア環境".](https://www.t4.gsic.titech.ac.jp/docs/handbook.ja/software/)
        - `module load intel` で利用できるモジュール(cudaなど)のバージョンが分かる

- datasetsのversionを確かめる
    - 2.21.0 でダメなら 2.19.2 で解決する人もいる
    - mbpp で失敗する issue: [Huggingface. google-research-datasets/mbpp. "This dataset is broken!".](https://huggingface.co/datasets/google-research-datasets/mbpp/discussions/5)


<br>

# 評価の実行

## 1. 評価するタスクの選択
対応するスクリプトを直接編集し、評価したいベンチマーク**ではない**行を全てコメントアウトしておく。

|モデルサイズ|vLLM|対応するスクリプト|
| -- | -- | -- |
| 13B 以下 | 使用 | `scripts/tsubame/node_q_vllm/qsub_all.sh` |
| 13B 以下 | 不使用 | `scripts/tsubame/node_q/qsub_all.sh` |
| 13B 超 | 使用 | `scripts/tsubame/node_v_vllm/qsub_all.sh` |
| 13B 超 | 不使用 | `scripts/tsubame/node_v/qsub_all.sh` |

なお、2024/12/03 時点で vLLM の評価に対応しているベンチマークは以下の通り。
- J/HumanEval
- JA/EN MBPP
- Harness EN
- MT-Bench

## 2. 評価スクリプトの実行
評価したいモデルを Huggingface の表記に従って `MODEL_NAME` に格納し、先に編集したスクリプトの引数に渡してキューを投げる。

実行例：
```bash
MODEL_NAME=tokyotech-llm/Llama-3.1-Swallow-8B-Instruct-v0.2
qsub -g tga-okazaki scripts/tsubame/node_q_vllm/qsub_all.sh $MODEL_NAME
```

## 3. 評価状況の確認
`scripts/tsubame/utils/save_and_check.sh` を実行することで評価の進捗状況を確認することができる。

出力例：
```bash
job_ID     state    node     vllm     slots    task               model name                                                                                          
-------------------------------------------------------------------------------------------------------------------------
1828500    done     node_v   _        48       ja_mt_bench        tokyotech-llm/Llama-3.1-Swallow-70B-Instruct-v0.1
1828503    done     node_v   _        48       ja_mbpp            tokyotech-llm/Llama-3.1-Swallow-70B-Instruct-v0.1
1828504    r        node_q   o        48       english_general    tokyotech-llm/Llama-3.1-Swallow-8B-Instruct-v0.1
1828506    r        node_q   o        48       english_mmlu       tokyotech-llm/Llama-3.1-Swallow-8B-Instruct-v0.1
1828507    r        node_q   o        48       english_bbh        tokyotech-llm/Llama-3.1-Swallow-8B-Instruct-v0.1
1828508    r        node_q   o        48       english_math       tokyotech-llm/Llama-3.1-Swallow-8B-Instruct-v0.1
1828511    qw       node_q   _        48       english_mbpp       tokyotech-llm/Llama-3.1-Swallow-8B-Instruct-v0.1
```


## 4. 結果の確認

- 全体の結果は`results/$MODEL_NAME/aggregated_result.json`に書き込まれる
- それぞれのベンチマークの結果は`results/$MODEL_NAME/`以下のそれぞれのディレクトリの中に書き込まれる


<br>

# 評価の詳細
## 評価スクリプトとベンチマークの対応

|スクリプト|対応するベンチマーク|
| -- | -- |
| `evaluate_english_bbh.sh` | BBH (論理推論・算術推論)
| `evaluate_english_general.sh` | TriviaQA (百科事典的知識・常識), GSM8K (算術推論), OpenBookQA (百科事典的知識・常識), Hellaswag (百科事典的知識・常識), XWINO(読解), SQuAD2(読解) |
| `evaluate_english_humaneval-unstripped.sh` | HumanEval (コード生成)|
| `evaluate_english_math.sh` | Math [minerva_math] (算術推論) |
| `evaluate_english_mbpp.sh` | MBPP (コード生成)|
| `evaluate_english_mbpp.sh` | MMLU (一般教養)|
| `evaluate_english.sh` (現在は不使用) | Harness En 全て (BBH, Math, MMLU, TriviaQA, GSM8K, OpenBookQA, Hellaswag, XWINO, SQuAD2) |
| `evaluate_ja_humaneval-unstripped.sh` | JHumanEval (コード生成)|
| `evaluate_ja_llmjp.sh` | NIILC (百科事典的知識・常識), JCommonsenseQA (百科事典的知識・常識), JSQuAD (読解) |
| `evaluate_ja_mbpp.sh` | JA MBPP (コード生成)|
| `evaluate_ja_mbpp.sh` | JMMLU (一般教養)|
| `evaluate_ja_mgsm.sh` | MGSM (算術推論) |
| `evaluate_ja_mt_bench.sh` | MT-Bench (会話)|
| `evaluate_ja_wmt20_enja.sh` | WMT20-en-ja (英日機械翻訳)|
| `evaluate_ja_wmt20_jaen.sh` | WMT20-ja-en (日英機械翻訳)|
| `evaluate_ja_xlsum.sh` | XL-SUM (要約)|

## 評価結果の表とベンチマークの対応
| 言語 | 大分類 | 小分類 |
| -- | -- | -- |
| EN | harness_en | gsm8k |
||| squad2 |
||| triviaqa |
||| hellaswag |
||| openbookqa |
||| xwinograd_en |
||| bbh_cot |
||| bbh_cot |
||| mmlu |
||| mmlu_social_sciences |
||| mmlu_humanities |
||| mmlu_stem |
||| mmlu_other |
|| humaneval | humaneval@1 |
||| humaneval@10 |
||| humaneval_answer@10 |
| JA | humaneval | jhumaneval@1 |
||| jhumaneval@10 |
||| jhumaneval_answer@10 |
|| llmjp| MC |
||| NLI |
||| QA |
||| RC |
||| jamp (NLI) |
||| janli (NLI) |
||| jcommonsenseqa |
||| jemhopqa |
||| jnli |
||| jsem |
||| jsick (NLI) |
||| jsquad |
||| jsts_pearson |
||| jsts_spearman |
||| niilc |
||| jmmlu |
||| jmmlu_social_sciences |
||| jmmlu_humanities |
||| jmmlu_stem |
||| jmmlu_other |
|| mgsm | MATH (mgsm_ja) |
|| wml20_en_ja | wmt20_en_ja_bleu |
|| wml20_ja_en | wmt20_ja_en_bleu |
|| xlsum | XLSUM_ja_1shot |