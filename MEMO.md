# FAQや今後実装したいことのメモ

## FAQ
- 日本語版MTBenchの評価対象モデルの出力はどこに保存されますか？
  - `jalm-evaluation-private/fastchat/fastchat/llm_judge/data/japanese_mt_bench/model_answer/`以下にモデルごとに保存されます。

<br>

- 日本語版MTBenchのJudge(GPT-4系列モデル)による評価結果はどこに保存されますか？
  - `jalm-evaluation-private/fastchat/fastchat/llm_judge/data/japanese_mt_bench/model_judgment/${judge_model_name}.jsonl`に保存されます。　\
  各行に一つの事例に対する評価結果が保存され、評価対象のモデル名が"model"に記録されています。
 
## 今後実装したいメモ
- 日本語版MTBenchのJudgeによる評価結果を評価対象のモデルごとに保存したい。
  - 現状の実装では全ての評価結果が一つのファイルに逐次追加されていく形で保存されるので、一つの評価対象モデルによる異なる出力をそれぞれ評価すると、\
    スコアの集計の際に過去の評価結果が考慮されてしまい正しくスコアの算出が行われない。
  - 評価対象のモデルごとに評価結果を毎回上書き保存するように変更すれば、上記の問題は起こらなくなるし、結果の確認も容易になる。