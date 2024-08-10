# 概要

- **(2024/08/11 中村 追記) TSUBAME4.0用のスクリプト**
- TSUBAME4.0で評価を回す方法
- 内部資料なので公開する予定はない
- 基本的なことは [readme](README.md)に書いてあるのでそちらを参照して下さい

## 準備

### パスの編集

- `scripts/tsubame/node_q/qsub_all.sh`
- `scripts/tsubame/node_f/qsub_all.sh`

**にハードコードされている以下の変数を自分の環境に合わせて編集する**

- `REPO_PATH`: `jalm-evaluation-private`の絶対パス
- `HUGGINGFACE_CACHE`: Huggingfaceのモデルの重みを置く場所
- `QSUB_CMD` : `qsub -g {グループ名}` `groups` コマンドで自分が使えるグループが確認できる

### 環境構築

**TODO : スクリプトを書く**

インタラクティブjobで環境構築する 

```bash
qrsh -g  {グループ名} -l node_q=1 -l h_rt=1:00:00
```

基本は、他の計算機同様の手順を踏む

中村は `pyenv 3.10.14` で検証しました

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

TSUBAMEでは、DockerイメージをApptainerイメージに変換します

```bash
apptainer pull docker://ghcr.io/bigcode-project/evaluation-harness
```

`evaluation-harness_latest.sif` として、 `jalm-evaluation-private/`に保存されます

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

## llm-jp-eval データセットの前処理

* [llm-jp-evalのREADME.md](https://github.com/llm-jp/llm-jp-eval/tree/main)に従って、データセットをダウンロードする

```bash
cd llm-jp-eval

python scripts/preprocess_dataset.py  \
--dataset-name all  \
--output-dir ./dataset

cd ../
```

## 評価

### 実行

ログインノードで以下のコマンドを実行

H100一枚で動くモデル（だいたい13B以下）の場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-7b-instruct-v0.1)
bash scripts/tsubame/node_q/qsub_all.sh $MODEL_NAME
```

それ以上のモデルの場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-7b-instruct-v0.1)
bash scripts/tsubame/node_f/qsub_all.sh $MODEL_NAME
```

### 結果の確認

- 全体の結果は`results/$MODEL_NAME/aggregated_result.json`に書き込まれる
- それぞれのベンチマークの結果は`results/$MODEL_NAME/`以下のそれぞれのディレクトリの中に書き込まれる
