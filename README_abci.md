# 概要

- ABCIで評価を回す方法
- 内部資料なので公開する予定はない
- 改良待ってます
- 質問があれば大井までお願いします
- 最終更新 (2024/05/28. 齋藤.)


# 初回だけやらなきゃいけない事

## 1. ABCIアカウントの発行
ABCIのアカウントを発行してもらい、グループ(`gag51395`)に入れてもらう。
> グループへの追加が上手くできていないと書き込み権限が付与されない

## 2. Web上での操作
### 2.1 ABCIへのログイン
[ABCI利用者ポータル](https://portal.abci.ai/user/)からログインをする。 \
ログインが成功するとログインURLが記載されたメールが送信されるので、そのリンクからページにアクセスする。 (*1, *2)
> *1: 迷惑メールに振り分けられることが多い \
> *2: 初回はパスワードの設定も行うことになる

### 2.2 公開鍵の登録
Hestia上でSSH鍵を作成し、そのうちの公開鍵を登録する。 \
登録はログイン後のページのサイドバーにある「公開鍵の登録」からできる。
> (j)humanevalではssh接続を用いてhestiaで評価の実行を行うようになっている

##　3. ローカルからABCIに接続するための準備
[ABCI 2.0 User Guide](https://docs.abci.ai/ja/getting-started/)の "Proxy Jumpの使用" を参考するなどして、ローカルからABCIにsshで繋げるようにする。 \
正しく設定できると、 `ssh abci` で接続できる。

## 4. ABCI上での操作
### 4.1 ローカルからABCIに接続する
`3._ローカルからABCIに接続するための準備`で設定したのを用いて `ssh abci` でABCIに接続する。

### 4.2 cacheディレクトリの作成
ログインノードで `mkdir -P /groups/gag51395/share/{your_name}/.cache` を実行し、自分用の cache ディレクトリを作成する。 (*3)
> *3: ここで Permission Denide になってしまう場合、`1. ABCIアカウントの発行`でグループに正しく追加されていない可能性がある

### 4.3 環境構築
ログインノードで `bash scripts/abci/environment/qsub_create_environment.sh` を実行し、環境構築を行う。 \
`qstat`でジョブの状況が確認できる。投げられたジョブが全て完了したら環境構築完了。

### 4.4 パスの設定
`4.3 環境構築`で作成された

- `scripts/abci/environment/qsub_create_environment.sh`
- `scripts/abci/rt_AF/qsub_all.sh`
- `scripts/abci/rt_AGsmall/qsub_all.sh`

にハードコードされている以下の変数を自分の環境に合わせて編集する

- `REPO_PATH`: ABCIの`jalm-evaluation-private`の絶対パス
- `GROUP_ID`: ABCIのグループのID (産総研のグループIDを指定してください。間違えて岡崎研のIDにすると岡崎研のお金を使ってしまいます。)
- `HUGGINGFACE_CACHE`: Huggingfaceのモデルの重みを置く場所。 `/groups/gag51395/share/{your_name}/.cache`というディレクトリを作り、それを使ってください。
- `LOCAL_PATH`: (j)humanevalの生成結果を置く**hestiaの**絶対パス。好きなところで良いですがディレクトリを消さないでください。

### 4.5 tokyotech-llmへの参加
Hugging Face にある東工大のllmグループ [tokyotech-llm](https://huggingface.co/tokyotech-llm) に参加申請を行い、参加する。

### 4.6 Hugging Face の access token 発行
[huggingface](https://huggingface.co/settings/tokens) で access token (*4)を生成する。
> *4: Readのトークンで良い

### 4.7 Hugging Face トークンの追加
ログインノードで `vim /groups/gag51395/share/{your_name}/.cache/token` を実行し、自身の access token を書いておく。 \
`cat /groups/gag51395/share/{your_name}/.cache/token` で `hf_XXXXXXXXXX` のように出力されればOK。




# 評価の手順

## 実行

ログインノードで以下のコマンドを実行

A100一枚で動くモデル（だいたい7B以下）の場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-7b-instruct-v0.1)
bash scripts/abci/rt_AGsmall/qsub_all.sh $MODEL_NAME
```

それ以上のモデルの場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-70b-hf)
bash scripts/abci/rt_AF/qsub_all.sh $MODEL_NAME
```

## 結果の確認

- 全体の結果は`results/$MODEL_NAME/aggregated_result.json`に書き込まれる
  - `overall`に載っているスコア（文字列）を評価結果を記入するスプレッドシートにコピペすればOKなはず
- それぞれのベンチマークの結果は`results/$MODEL_NAME/`以下のそれぞれのディレクトリの中に書き込まれる
