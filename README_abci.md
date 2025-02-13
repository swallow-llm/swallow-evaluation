# 目次

- [概要](#概要)
- [A. 初回準備](#A-初回準備)
    - [1. ABCIアカウントの発行](#1-ABCIアカウントの発行)
    - [2. ABCIへのログイン](#2-ABCIへのログイン)
    - [3. ローカルからABCIに接続するための準備](3-ローカルからABCIに接続するための準備)
    - [4. ABCI上での操作](4-ABCI上での操作)
- [B. 評価の実行](#B-評価の実行)
    - [1. 評価するタスクの選択](#1-評価するタスクの選択)
    - [2. 評価スクリプトの実行](#2-評価スクリプトの実行)
    - [3. 評価状況の確認](#3-評価状況の確認)
    - [4. 結果の確認](#4-結果の確認)
- [C. 評価の詳細](#C-評価の詳細)
    - [評価スクリプトとベンチマークの対応](#評価スクリプトとベンチマークの対応)
    - [評価結果の表とベンチマークの対応](#評価結果の表とベンチマークの対応)


# 概要

- ABCIで評価を回す方法
- 内部資料なので公開する予定はない
- 改良待ってます
- 質問があれば大井までお願いします
- 最終更新 (2025/02/09. 齋藤.)

<br>


# A. 初回準備
## 1. ABCIアカウントの発行
ABCIのアカウントを発行してもらい，グループ(`gag51395`)に入れてもらう．
> グループへの追加が上手くできていないと書き込み権限が付与されない．


## 2. ABCIへのログイン
[ABCI利用者ポータル](https://portal.abci.ai/user/)からログインをする． \
ログインが成功するとログインURLが記載されたメールが送信されるので，そのリンクからページにアクセスする．

> 迷惑メールに振り分けられることが多い．\
> また，初回はパスワードの設定も行うことになる．


## 3. ローカルからABCIに接続するための準備
公式のドキュメントである[ABCI 3.0 User Guide. "Proxy Jumpの使用".](https://docs.abci.ai/v3/ja/getting-started/#proxyjump)や，先輩が執筆された esa，["ABCIに圧倒的入門するためのページ"](https://nlp.esa.io/posts/2006)を参考にして，ローカルからABCIにsshで繋げるようにする． \
正しく設定できるとターミナルやVSCodeから接続できるようになる，


### 3.1 ssh鍵の作成
自分のパソコン上で ssh 鍵を作成する．\
以下のコードをターミナルに打ち込めば良い．

```bash
ssh-keygen -f id_rsa_abci3
```

実行すると `~/.ssh/id_rsa_abci3`（秘密鍵：他の人に教えちゃいけない鍵）と `~/.ssh/id_rsa_abci3.pub`（公開鍵：接続する相手に教える鍵）が生成されるはずである．

- [note. "sshキー(秘密鍵・公開鍵)の作成と認証　流れ". @soma_sekimoto 
(soma).](https://qiita.com/soma_sekimoto/items/35845495bc565c38ae9d)
- [ITmedia. "【 ssh-keygen 】コマンド――SSHの公開鍵と秘密鍵を作成する"](https://atmarkit.itmedia.co.jp/ait/articles/1908/02/news015.html)


### 3.2 公開鍵の登録．
3.1 で生成した ssh 鍵のうち，公開鍵（`~/.ssh/id_rsa_abci3.pub`）を登録する． \
登録には abci3-qa@abci.ai まで連絡を取る必要がある．

- [ABCI 3.0 User Guide. "前提".](https://docs.abci.ai/v3/ja/getting-started/#prerequisites)


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
`3.ローカルからABCIに接続するための準備`で設定した上で VSCode から ABCI3.0 に接続する．


### 4.2 cacheディレクトリの作成
ログインノード（`/home/{ユーザ名}`）で `mkdir -P /groups/gag51395/share/{your_name}/.cache` を実行し，自分用の cache ディレクトリを作成する． (*6)
> *6: ここで Permission Denide になってしまう場合，`1. ABCIアカウントの発行`でグループに正しく追加されていない可能性がある


### 4.3 `jalm_evaluation_private`のクローン
#### 4.3.1 GitHub への公開鍵登録 (WIP)
GitHub からのクローンを行うために，ABIC上で作成した ssh 鍵のうち，公開鍵をGitHub へ登録する必要がある． \
鍵の生成には「A.3.1 ssh鍵の作成」で用いたものと同様のコードを用いれば良い． \
なお，名前の設定`-f`は任意である．
```bash
ssh-keygen
```

こうして生成した鍵のうち，公開鍵の方(`~/.ssh/id_rsa.pub`)を GitHub に登録しておく． \
登録は [GitHub](https://github.com/) → 右上のアイコン → Settings → SSH and GPG keys → New SSH key からできる．

- [GitHub Docs. "GitHub アカウントへの新しい SSH キーの追加".](https://docs.github.com/ja/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)



#### 4.3.2 URLの入手
[レポジトリ](https://github.com/nlp-titech/jalm-evaluation-private)から本評価フレームワークをクローンするためのURLを入手する． \
左上にある緑色の`<> Code`というボタンをクリックし，`HTTPS`タブで表示されているURLをコピーする．


#### 4.3.3 自分のディレクトリへのクローン
ログインノード（`/home/{ユーザ名}`）以下の好きな場所に本評価フレームワークをクローンする． \
もし他の実験のために他のレポジトリもクローンすることが考えられる場合は，`/home{ユーザ名}/github`というディレクトリを作り，その中でクローンすると良いだろう．

具体的なクローンのコマンドは以下の通りだ．
```bash
cd /home{ユーザ名}/github
git clone {4.3.1で得たURL}
```

もし，特定のブランチ（バージョン）を指定されていた場合は，以下のコマンドを実行すれば良い．
```bash
cd /home{ユーザ名}/github
git clone -b {指定されたブランチ名} {4.3.1で得たURL}
```

### 4.4 評価で用いる変数の設定
#### 4.4.1 環境変数への登録
評価で用いるパスは環境変数として登録する． \
ただし，ABCI3.0 のログインノード（`/home/{ユーザ名}`）には， `.bash_profile` と `.bashrc` がデフォルトでは作られていない．
そこでそれらを用意する必要がある．

まず `.bash_profile` を用意する． \
ログインノード（`/home/{ユーザ名}`）で以下を実行し `.bash_profile` を作成する．
```bash
vim .bash_profile
```
そのまま，開かれた画面で以下を追記する．
```text
if [ -f ~/.bashrc ] ; then
    . ~/.bashrc
fi
```

編集画面を `:` と `qw` で上書きした上で終了する． \
次に評価で用いる環境変数を`~/.bashrc`に登録する。

```bash
vim ~/.bashrc
```
そのまま，開かれた画面で以下を追記する． \
なお，`{username}` は評価者によって異なる．
```text
# Swallow-Evaluation environment
export SWALLOW_EVAL_ROOT="/home/{username}/jalm-evaluation-private"
export SWALLOW_EVAL_CACHEDIR="/home/{username}/.cache/"
export SWALLOW_EVAL_PIP_CACHEDIR="${SWALLOW_EVAL_CACHE}/pip"
export SWALLOW_EVAL_HUGGINGFACE_CACHEDIR="${SWALLOW_EVAL_CACHE}/huggingface"
export SWALLOW_EVAL_SINGULARITY_CACHEDIR="${SWALLOW_EVAL_CACHE}/singularity"
```
また，各評価者にとって管理しやすいパスがある場合には，上記の例に合う形でなくとも良い．

| 変数名 | 役割 |
| -- | -- |
| `SWALLOW_EVAL_ROOT` | `jalm-evaluation-private`の絶対パス。 |
| `SWALLOW_EVAL_PIP_CACHEDIR` | `pip install`のキャッシュを置く場所（環境構築の際に使用）。|
| `SWALLOW_EVAL_HUGGINGFACE_CACHEDIR` | Huggingfaceのモデルの重みを置く場所（評価の際に使用）。|
| `SWALLOW_EVAL_SINGULARITY_CACHEDIR` | SINGULARITYのキャッシュを置く場所（J/HumanEvalやJ/MBPPの評価時に使用）。|

環境変数を登録したくない場合は、自身で以下のファイルの環境変数を用いる部分をハードコーディングすれば良い。

- scripts/abci/environment/qsub_create_environment.sh
- scripts/abci/rt_HF/qsub_all.sh
- scripts/abci/rt_HG/qsub_all.sh

追記が終わったら、以下のコードをコマンドラインで実行し、先に設定した環境変数の設定を反映する。
```bash
source ~/.bashrc
```

#### 4.4.2 ハードコーディングされた変数の修正
評価に用いる変数のうち， `GROUP_ID` はお金に関わる重要な項目なので，
環境変数への登録はせず，ハードコーディングを適宜修正する形を採用している．

まず，自分の`jalm-evaluation-private`まで移動する． \
そこで `vim`などを用いて以下のファイルにハードコーディングされている `GROUP_ID` を自分に合うように書き直す．

- scripts/abci/environment/qsub_create_environment.sh
- scripts/abci/rt_HF/qsub_all.sh
- scripts/abci/rt_HG/qsub_all.sh

| 変数名 | 役割 |
| -- | -- |
|`GROUP_ID`|ABCIのグループのID．（基本的には産総研のグループIDを指定すること．間違えて岡崎研のIDにすると岡崎研のお金を使ってしまう．）|


### 4.5 Pythonのバージョン設定
pyenv を使って、`jalm_evaluation_private`以下のpythonのデフォルトのバージョンを3.10.14に設定する。
pyenv を既にインストールしている場合は 4.5.1，4.5.2，4.5.3 をスキップして 4.5.4 から行うこと。
なお、以下の手順はこちらを参考にした。
- [pyenvを使った設定方法の参考資料（tsubame 3.0の資料だが、tsubame 4.0にも適用可能)](https://rioyokotalab.github.io/python-supercomputer/)


#### 4.5.1 pyenv のインストール
以下のコードをログインノード（`/home/{ユーザ名}`）で実行。
```bash
curl https://pyenv.run | bash
```


#### 4.5.2 環境変数の登録
pyenvに必要な環境変数を登録する．
```bash
vim .bashrc
```
そのまま，開かれた画面で以下を追記する．。
```text
# User specific environment
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
```


#### 4.5.3 環境変数の反映
以下のコードをコマンドラインで実行し、先に設定した環境変数の設定を反映する。
```bash
source ~/.bashrc
```


#### 4.5.4 python のインストール
以下のコードをコマンドラインで実行し、必要な python をインストールする。
```bash
pyenv install 3.10.14
```

#### 4.3.5 python のバージョンを指定
以下のいずれかの方法で先にインストールした python のバージョンが評価ディレクトリで使われるように指定する。

A) 全てのディレクトリのデフォルトのバージョンが3.10.14になって良い場合
```bash
pyenv global 3.10.14
```

B) `jalm_evaluation_private`以下のデフォルトのバージョンだけを3.10.14にしたい場合(推奨)
```bash
cd /path/to/your/jalm_evaluation_private
pyenv local 3.10.14
```

### 4.6 環境構築スクリプトの実行
`bash scripts/abci/environment/qsub_create_environment.sh` を実行し，環境構築のためのジョブを投げる． \

これにより五つのジョブが流れ、以下の環境構築が行われる。
| ジョブ(環境)の名前 | 対応する評価タスク|
|--|--|
|`bigcode`|J/HumanEvalやJA/EN MBPP|
|`fastchat`| MT-Bench |
|`llm-jp-eval`| llmjp |
|`lm-harness-en`| BBH, MATH, MMLU, GPQA, General(TriviaQA, GSM8K, OpenBookQA, Hellaswag, XWINO, SQuAD2) |
|`lm-harness-jp` | MGSM, XL-SUM, WMT20-EN-JA, WMT20-JA-EN | の評価に使う環境の構築

なお、各環境を以下のように個別に構築することもできる。

`bigcode`の例：
```bash
bash scripts/abci/environment/bigcode.sh $SWALLOW_EVAL_ROOT $SWALLOW_EVAL_PIP_CACHEDIR $SWALLOW_EVAL_SINGULARITY_CACHEDIR
```

各環境の詳細(ライブラリの構成など)は `scripts/abci/environment/` 以下のコードを参照されたい。
また、実行時のログについては `~/.SE_crtenv_bigcode` のように出力されるので必要な際は確認されたい。


### 4.7 tokyotech-llmへの参加
Hugging Face にある東工大のllmグループ [tokyotech-llm](https://huggingface.co/tokyotech-llm) に参加申請を行い，参加する．


### 4.8 HuggingFace と OpenAI の Token 登録
モデルのアクセスのために HuggingFace と OpenAI の Token が必要になるので登録しておく．
```bash
echo OPENAI_API_KEY=sk-... >> ${SWALLOW_EVAL_ROOT}/.env
echo HF_TOKEN=hf_... >> ${SWALLOW_EVAL_ROOT}/.env

echo hf_... >> ${SWALLOW_EVAL_CACHE}/token
```

- [Qiita. "OpenAIのAPIキー取得方法|2024年7月最新版|料金体系や注意事項".](https://qiita.com/kurata04/items/a10bdc44cc0d1e62dad3)
- [Edge HUB. "Hugging Faceの使い方！アクセストークン作成からログインまで".](https://highreso.jp/edgehub/machinelearning/huggingfacetoken.html)


### 4.9 評価スクリプトへの実行権限付加
ABCI3.0 では評価スクリプトにユーザへの実行権限を付加する必要がある． \
具体的には以下のコードでそれを実現できる．
```bash
chmod u+x ${SWALLOW_EVAL_ROOT}/scripts/abci/rt_H*/evaluate_*.sh
```

なお，実行権限が正しく付与されたかどうかは `ls -l` を使って確かめることができる．

- [note. "Linuxの権限確認と変更(chmod)（超初心者向け）". Masashi Hirano.](https://qiita.com/shisama/items/5f4c4fa768642aad9e06)


<br>

# B. 評価の手順
## 1. 評価するタスクの選択
対応するスクリプトを直接編集し、評価**しない**ベンチマークの行は全てコメントアウトしておく。

|モデルサイズ|対応するスクリプト|
| -- | -- |
| 13B 以下 | `scripts/abci/rt_HG/qsub_all.sh` |
| 13B 超 | `scripts/abci/rt_HF/qsub_all.sh` |


## 2. 評価スクリプトの実行
評価したいモデルを Huggingface の表記に従って `MODEL_NAME` に格納し、先に編集したスクリプトの引数に渡してキューを投げる。

実行例 (`tokyotech-llm/Llama-3.1-Swallow-8B-Instruct-v0.2`の場合)：
```bash
MODEL_NAME=tokyotech-llm/Llama-3.1-Swallow-8B-Instruct-v0.2
bash ${SWALLOW_EVAL_ROOT}/scripts/abci/rt_HG/qsub_all.sh $MODEL_NAME
```

## 3. 評価状況の確認
`scripts/abci/utils/save_and_check_qstat.sh` を実行することで評価の進捗状況を確認することができる。

出力サンプル：
```txt
job_ID       state    node     task          model name                                                                                          
---------------------------------------------------------------------------------------------------
80329.pbs1   R        rt_HG    HumanEval     tokyotech-llm_Llama-3.1-Swallow-8B-Instruct-v0.2  
80330.pbs1   R        rt_HG    JHumanEval    tokyotech-llm_Llama-3.1-Swallow-8B-Instruct-v0.2  
80331.pbs1   done     rt_HG    MBPP          tokyotech-llm_Llama-3.1-Swallow-8B-Instruct-v0.2                    
```

## 4. 結果の確認
- 全体の結果は`results/{MODEL NAME}/aggregated_result.json`に書き込まれる
  - `overall`に載っているスコア（文字列）を評価結果を記入するスプレッドシートにそのままコピペすればOK
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


## C. 状況に応じて必要になる追加の操作
### 1. huggingface-cli
- モデルを評価が開始される前にロードしておきたい．
- モデルが正しくロードできるか試したい．

以上のような場合，`huggingface-cli`（コマンドライン用の huggingface） を使うことで目的を叶えることができる．

#### 1.1 huggignface-cli のインストール
適当な pyenv を選び，その中で huggingface-cli をインストールする．

実行例（`.venv_bigcode`を選んだ場合）：
```bash
source .venv_bigcode/bin/activate
pip install huggingface-cli --cache-dir ${SWALLOW_EVAL_PIP_CACHEDIR}
```


#### 1.2 huggingface へのログイン
以下のコマンドで huggingface へのログインを行う． \
hugginface の token が必要になる．

```bash
huggingface-cli login
```

なお，途中で `Add token as git credential?` と訊かれるが，これは `n`（No）で良い．


#### 1.3 モデルの事前ダウンロード
以下のコマンドで評価に先立ってモデルを特定のキャッシュにダウンロードすることができる． \
評価時間の短縮につながる．
```bash
MODEL_NAME=...
huggingface-cli download $MODEL_NAME --cache-dir $SWALLOW_EVAL_HUGGINGFACE_CACHEDIR
```


### 2. Git 情報の登録
本フレームワークをアップデートするにあたり，その修正後の版をリモートに `push` することがあるだろう． \
その際に `Please tell me who you are.` と訊かれることがある． \
これを解決するには Git 情報の登録が必要となる．

#### 2.1 メールアドレスの登録
以下のコマンドから Git の　log に表示するメールアドレスを登録する． \
GitHub に登録しているものと同じで良い．
```bash
git config --global user.email "your@email.com"
```

#### 2.2 ユーザ名の登録
以下のコマンドから Git の　log に表示するユーザ名を登録する． \
GitHub に登録しているものと同じで良い．
```bash
git config --global user.name "yourname"
````


# D. 評価の詳細
## 1. 評価スクリプトとベンチマークの対応

|スクリプト|対応するベンチマーク|
| -- | -- |
| `evaluate_english_bbh.sh` | BBH (論理推論・算術推論)
| `evaluate_english_general.sh` | TriviaQA (百科事典的知識・常識), GSM8K (算術推論), OpenBookQA (百科事典的知識・常識), Hellaswag (百科事典的知識・常識), XWINO(読解), SQuAD2(読解) |
| `evaluate_english_humaneval-unstripped.sh` | HumanEval (コード生成)|
| `evaluate_english_math.sh` | Math [hendrycksmath2021から、OpenAIの"Let's Verify Step by Step"に倣って500問をサンプリング] (算術推論) |
| `evaluate_english_mbpp.sh` | MBPP (コード生成)|
| `evaluate_english_mbpp.sh` | MMLU (一般教養)|
| `evaluate_english_gpqa.sh` | GPQA（博士課程）|
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

## 2. 評価結果の表とベンチマークの対応
| 言語 | 大分類 | 小分類 |
| -- | -- | -- |
| EN | harness_en | gsm8k |
||| squad2 |
|||squad2_best_exact |
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
||| math_500 |
||| gpqa_main_meta_llama3_cot_zeroshot |
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
