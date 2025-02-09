# 概要

- ABCIで評価を回す方法
- 内部資料なので公開する予定はない
- 改良待ってます
- 質問があれば大井までお願いします
- 最終更新 (2025/02/09. 齋藤.)


# 初回だけやらなきゃいけない事

## 1. ABCIアカウントの発行
ABCIのアカウントを発行してもらい，グループ(`gag51395`)に入れてもらう．
> グループへの追加が上手くできていないと書き込み権限が付与されない

## 2. ABCIへのログイン
[ABCI利用者ポータル](https://portal.abci.ai/user/)からログインをする． \
ログインが成功するとログインURLが記載されたメールが送信されるので，そのリンクからページにアクセスする．（注意：*1，*2）

> *1: 迷惑メールに振り分けられることが多い \
> *2: 初回はパスワードの設定も行うことになる

## 3. ローカルからABCIに接続するための準備
公式のドキュメントである[ABCI 3.0 User Guide. "Proxy Jumpの使用".](https://docs.abci.ai/v3/ja/getting-started/#proxyjump)や，先輩が執筆された esa，["ABCIに圧倒的入門するためのページ"](https://nlp.esa.io/posts/2006)を参考にして，ローカルからABCIにsshで繋げるようにする． \
正しく設定できるとターミナルやVSCodeから接続できるようになる，

### 3.1 ssh鍵の作成
自分のパソコン上で ssh 鍵を作成する．（参考：*3，*4）\
以下のコードをターミナルに打ち込めば良い．

```bash
ssh-keygen -t ed25519 -f id_rsa_abci3
```

実行すると `~/.ssh/id_rsa_abci3`（秘密鍵：他の人に教えちゃいけない鍵）と `~/.ssh/id_rsa_abci3.pub`（公開鍵：接続する相手に教える鍵）が生成されるはずである．

> *3: [note. "sshキー(秘密鍵・公開鍵)の作成と認証　流れ". @soma_sekimoto 
(soma).](https://qiita.com/soma_sekimoto/items/35845495bc565c38ae9d) \
> *4: [ITmedia. "【 ssh-keygen 】コマンド――SSHの公開鍵と秘密鍵を作成する"](https://atmarkit.itmedia.co.jp/ait/articles/1908/02/news015.html)


### 3.2 公開鍵の登録．
3.1 で生成した ssh 鍵のうち，公開鍵（`~/.ssh/id_rsa_abci3.pub`）を登録する． \
登録には abci3-qa@abci.ai まで連絡を取る必要がある．（参考：*5）

> *5: [ABCI 3.0 User Guide. "前提".](https://docs.abci.ai/v3/ja/getting-started/#prerequisites)


### 3.3 ssh config の作成
`~/.ssh/config`に以下を加筆する．

```text
Host abci3
     HostName login
     User {Your Username}
     ProxyJump %r@as.v3.abci.ai
     IdentityFile /Users/{Your Name}/.ssh/id_rsa_abci3

Host as.v3.abci.ai
     IdentityFile /Users/{Your Name}/.ssh/id_rsa_abci3
```

- {Your Username}：ABCI3.0におけるユーザー名．
- {Your Name}：パソコンにおける名前．鍵までのパスが合っていれば良い．


## 4. ABCI上での操作
### 4.1 ローカルからABCIに接続する
`3.ローカルからABCIに接続するための準備`で設定したのを用いて `ssh abci` でABCIに接続する．

### 4.2 cacheディレクトリの作成
ログインノードで `mkdir -P /groups/gag51395/share/{your_name}/.cache` を実行し，自分用の cache ディレクトリを作成する． (*6)
> *6: ここで Permission Denide になってしまう場合，`1. ABCIアカウントの発行`でグループに正しく追加されていない可能性がある

### 4.3 環境構築のためのパスの設定
自分の`jalm-evaluation-private`まで移動する． \
そこで `vim`などを用いて`scripts/abci/environment/qsub_create_environment.sh`にハードコーディングされている以下のパスを自分に合うように書き直す．

- `REPO_PATH`: 自分の`jalm-evaluation-private`までの絶対パス．
- `PIP_CACHEDIR`: `pip install` で使われるキャッシュディレクトリまでのパス． 
- `SINGULARITY_CACHEDIR`: コーディング系の評価ベンチマークを実行するために用いる仮想コンテナ Singularity で使われるキャッシュディレクトリまでのパス． 
- `GROUP_ID`: ABCIのグループのID．（産総研のグループIDを指定すること．間違えて岡崎研のIDにすると岡崎研のお金を使ってしまう．）

### 4.4 環境構築スクリプトの実行
`bash scripts/abci/environment/qsub_create_environment.sh` を実行し，環境構築のためのジョブを投げる． \
`qstat`でジョブの状況が確認できる．投げられたジョブが全て完了したら環境構築完了．

### 4.5 評価実行のためのパスの設定
- `scripts/abci/rt_HF/qsub_all.sh`
- `scripts/abci/rt_HG/qsub_all.sh`

にハードコーディングされている以下の変数を自分の環境に合わせて編集する

- `REPO_PATH`: 自分の`jalm-evaluation-private`までの絶対パス．
- `GROUP_ID`: ABCIのグループのID．（産総研のグループIDを指定すること．間違えて岡崎研のIDにすると岡崎研のお金を使ってしまう．）
- `HUGGINGFACE_CACHE`: Huggingfaceのモデルの重みを置く場所． `/groups/gag51395/share/{Your Name}/.cache`というディレクトリを作り，それを使う．
  - gag51395への書き込み権限がない場合，産総研のグループにアカウントが追加されていないので追加してもらうこと．

### 4.6 tokyotech-llmへの参加
Hugging Face にある東工大のllmグループ [tokyotech-llm](https://huggingface.co/tokyotech-llm) に参加申請を行い，参加する．

### 4.7 HuggingFace と OpenAI の Token 登録
モデルのアクセスのために HuggingFace と OpenAI の Token が必要になるので登録しておく．
```bash
CACHE_DIR="/groups/gag51395/share/{Your Name}/.cache"
echo OPENAI_API_KEY=sk-... >> ${CACHE_DIR}/token
echo HF_TOKEN=hf_... >> ${CACHE_DIR}/token
```

# 評価の手順

## 実行

ログインノードで以下のコマンドを実行

A100一枚で動くモデル（だいたい21B以下）の場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-7b-instruct-v0.1)
bash scripts/abci/rt_HG/qsub_all.sh $MODEL_NAME
```

それ以上のモデルの場合は

```bash
MODEL_NAME=評価したいモデルのhuggingfaceの名前 (e.g. tokyotech-llm/Swallow-70b-hf)
bash scripts/abci/rt_HF/qsub_all.sh $MODEL_NAME
```

## 結果の確認

- 全体の結果は`results/{MODEL NAME}/aggregated_result.json`に書き込まれる
  - `overall`に載っているスコア（文字列）を評価結果を記入するスプレッドシートにコピペすればOKなはず
- それぞれのベンチマークの結果は`results/{MODEL NAME}/`以下のそれぞれのディレクトリの中に書き込まれる
- `scripts/show_results.py`を使うと複数モデルの結果を一気にコピペできる

```bash
# model_list.txtにモデルを改行区切りで書く
> python scripts/show_result.py --model model_list.txt

model,XLSUM_ja_1shot,MATH (mgsm_ja),wmt20_en_ja_bleu,wmt20_ja_en_bleu,MC,NLI,QA,RC,jamp (NLI),janli (NLI),jcommonsenseqa,jemhopqa,jnli,jsem,jsick (NLI),jsquad,jsts_pearson,jsts_spearman,niilc,jmmlu,jmmlu_social_sciences,jmmlu_humanities,jmmlu_stem,jmmlu_other,jhumaneval@1,jhumaneval@10,jhumaneval_answer@10,MT-Bench (ALL),writing,roleplay,reasoning,math,coding,extraction,stem,humanities,gsm8k,squad2,triviaqa,hellaswag,openbookqa,xwinograd_en,bbh_cot,mmlu,mmlu_social_sciences,mmlu_humanities,mmlu_stem,mmlu_other,humaneval@1,humaneval@10,humaneval_answer@10
tokyotech-llm/Llama-3-70b-exp6-LR1.0e-5-MINLR1.0E-6-WD0.1-iter0002500,0.2340341110903234,0.656,0.2923692644226212,0.2515897494904012,0.9589,0.71104,0.64045,0.9196,0.6092,0.7847,0.9589,0.6316,0.5998,0.8024,0.7591,0.9196,0.8798,0.8504,0.6493,0.694719005930528,0.7407407407407407,0.7730220492866408,0.6056338028169014,0.7119628339140535,0.1652439024390244,0.2682926829268293,0.3780487804878049,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,-1.0,0.7983320697498104,0.40394171649962096,0.8264600980829246,0.6851224855606453,0.43,0.9234408602150538,0.722162494240516,0.776 
 
# 特定のタスクだけ出力させたいときは，タスク名をコンマ区切りで指定する 
> python scripts/show_result.py --model model_list.txt --tasks "jhumaneval-unstripped@1,jhumaneval-unstripped@10,jhumaneval-unstripped_answer@10,humaneval-unstripped@1,humaneval-unstripped@10,humaneval-unstripped_answer@10"
```

これをコピーしてスプレッドシートに shift + cmd + V でペースト -> 「テキストを列に分割」 で簡単に結果の記入ができる
