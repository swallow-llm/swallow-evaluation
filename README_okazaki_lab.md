# 概要

- 岡崎研のhestiaで評価を回す方法
- 内部資料なので公開する予定はない
- 基本的なことは [readme](README.md)に書いてあるのでそちらを参照して下さい
- 改良待ってます

## 準備

[readme](README.md)にしたがって環境構築・llm-jp-eval データセットの前処理を行ってください。

## 評価

### 実行

直接 `scripts/evaluate_*.sh`を実行しても評価ができますが、簡単のために日本語のタスクをまとめて評価するスクリプトと英語のタスクをまとめて評価するスクリプトがあります。

評価の前に、使うGPUのIDと数を決めてください。 `nvidia-smi`でGPUの使用状況が確認できるので、7bのモデルの場合は1つ、13bのモデルの場合は2つ、70bのモデルの場合は4つ、空いているGPUのIDを決めて以下のようにIDと数を指定してください。

```bash
# 70bのモデルを評価する際、GPU0,1,2,3が空いていた場合
CUDA_VISIBLE_DEVICES="0,1,2,3"
GPU_NUM=4
```

#### 日本語の評価実行

```bash
MODEL_NAME_PATH=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-7b-instruct-v0.1)
bash scripts/okazaki_lab/evaluate_ja_tasks.sh $MODEL_NAME_PATH $CUDA_VISIBLE_DEVICES $GPU_NUM
```

#### 英語の評価実行

```bash
MODEL_NAME_PATH=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-7b-instruct-v0.1)
bash scripts/okazaki_lab/evaluate_en_tasks.sh $MODEL_NAME_PATH $CUDA_VISIBLE_DEVICES $GPU_NUM
```

### 結果の確認

- 全体の結果は`results/$MODEL_NAME/aggregated_result.json`に書き込まれる
- それぞれのベンチマークの結果は`results/$MODEL_NAME/`以下のそれぞれのディレクトリの中に書き込まれる
