# 概要

- ABCIで評価を回す方法
- 内部資料なので公開する予定はない
- 基本的なことは [readme](README.md)に書いてあるのでそちらを参照して下さい
- 改良待ってます
- 質問があれば大井までお願いします

## 準備

### hestiaへの公開鍵の登録

**ABCIで**公開鍵を生成し、hestiaに自分のアカウントでsshできるようにする。

公開鍵のhestiaへの登録はサーバー係に依頼してください。

(j)humanevalではssh接続を用いてhestiaで評価の実行を行うようになっている。

### パスの編集

- `scripts/abci/environment/qsub_create_environment.sh`
- `scripts/abci/rt_AF/qsub_all.sh`
- `scripts/abci/rt_AGsmall/qsub_all.sh`

にハードコードされている以下の変数を自分の環境に合わせて編集する

- `REPO_PATH`: ABCIの`jalm-evaluation-private`の絶対パス
- `GROUP_ID`: ABCIのグループのID (産総研のグループIDを指定してください。間違えて岡崎研のIDにすると岡崎研のお金を使ってしまいます。)
- `HUGGINGFACE_CACHE`: Huggingfaceのモデルの重みを置く場所。岡崎研の人は容量削減のために `/groups/gcb50243/share/.cache`を使ってください。
- `LOCAL_PATH`: (j)humanevalの生成結果を置く**hestiaの**絶対パス。好きなところで良いですがディレクトリを消さないでください。

### llm-jp-eval データセットの前処理

[readme](README.md)にしたがって同じことをする

### 環境構築

ログインノードで以下のコマンドを実行

```bash
bash scripts/abci/environment/qsub_create_environment.sh
```

それぞれの環境を構築するためのジョブが投げられる。

`qstat`でジョブの状況が確認できる。投げられたジョブが全て完了したら環境構築完了。

## 評価

### 実行

ログインノードで以下のコマンドを実行

H100一枚で動くモデル（だいたい10B以下）の場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-7b-instruct-v0.1)
bash scripts/abci/rt_AGsmall/qsub_all.sh $MODEL_NAME
```

それ以上のモデルの場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-70b-hf)
bash scripts/abci/rt_AF/qsub_all.sh $MODEL_NAME
```

### 結果の確認

- 全体の結果は`results/$MODEL_NAME/aggregated_result.json`に書き込まれる
  - `overall`に載っているスコア（文字列）を評価結果を記入するスプレッドシートにコピペすればOKなはず
- それぞれのベンチマークの結果は`results/$MODEL_NAME/`以下のそれぞれのディレクトリの中に書き込まれる
