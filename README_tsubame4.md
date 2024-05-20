# 概要

- **(2024/05/21追記)TSUBAME4.0用のスクリプトはアップデートされていないので使えません。ABCI用のスクリプトを使って下さい。必要があればアップデートします。**
- TSUBAME4.0で評価を回す方法
- 内部資料なので公開する予定はない
- 基本的なことは [readme](README.md)に書いてあるのでそちらを参照して下さい
- 改良待ってます

## 準備

### パスの編集

- `scripts/tsubame/environment/qsub_create_environment.sh`
- `scripts/tsubame/gpu_1/qsub_all.sh`
- `scripts/tsubame/node_f/qsub_all.sh`

にハードコードされている以下の変数を自分の環境に合わせて編集する

- `REPO_PATH`: `jalm-evaluation-private`の絶対パス
- `GROUP_ID`: TSUBAME4.0のグループのID (岡崎研の人はそのままでOKのはず)
- `HUGGINGFACE_CACHE`: Huggingfaceのモデルの重みを置く場所. 岡崎研の人は `/gs/bs/tga-okazaki/`以下に自分のフォルダを作ってcacheを指定してください

### llm-jp-eval データセットの前処理

[readme](README.md)にしたがって同じことをする

### 環境構築

ログインノードで以下のコマンドを実行

```bash
bash scripts/tsubame/environment/qsub_create_environment.sh
```

それぞれの環境を構築するためのジョブが投げられる。

`qstat`でジョブの状況が確認できる。投げられたジョブが全て完了したら環境構築完了。

## 評価

### 実行

ログインノードで以下のコマンドを実行

H100一枚で動くモデル（だいたい13B以下）の場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-7b-instruct-v0.1)
bash scripts/tsubame/gpu_1/qsub_all.sh $MODEL_NAME
```

それ以上のモデルの場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-7b-instruct-v0.1)
bash scripts/tsubame/node_f/qsub_all.sh $MODEL_NAME
```

### 結果の確認

- 全体の結果は`results/$MODEL_NAME/aggregated_result.json`に書き込まれる
- それぞれのベンチマークの結果は`results/$MODEL_NAME/`以下のそれぞれのディレクトリの中に書き込まれる
- **humaneval/jhumanevalのみは評価にdocker環境が必要なので、tsubameでは評価ができない**
  - 出力結果のファイル `results/$MODEL_NAME/ja/humaneval/generation_jhumaneval.json`と`results/$MODEL_NAME/en/humaneval/generation_humaneval.json`をdockerを使える環境（岡崎研ならhestia）にrsyncなどでダウンロードして評価する必要がある
