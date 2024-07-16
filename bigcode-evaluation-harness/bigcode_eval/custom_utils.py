import regex
from typing import List

# single quotation による docstring
DOCSTRING_SUFFIX_double_quote = '"""'

# double quotation による docstring
DOCSTRING_SUFFIX_single_quote = "'''"

def _strip_leading_non_literals(code_snippet: str) -> str:
    r_control_codes = regex.compile(r'^[\t\s"]{1,}')
    return r_control_codes.sub("", code_snippet)

def _is_empty_answer(code_snippet: str, sep: str) -> bool:
    answer_span = code_snippet.split(sep)[-1]
    return len(_strip_leading_non_literals(answer_span)) == 0

def if_no_answer(lst_code_snippet: List[str]) -> bool:
    sq = all(map(lambda s: _is_empty_answer(s, DOCSTRING_SUFFIX_single_quote), lst_code_snippet))
    dq = all(map(lambda s: _is_empty_answer(s, DOCSTRING_SUFFIX_double_quote), lst_code_snippet))
    return (sq or dq)

def calculate_answer_ratio(lst_lst_code_snippets: List[List[str]]) -> float:
    """
    HumanEval / JHumanEval タスクで生成されるコードスニペットのリストのリストを受け取り、設問に対する回答率を計算します。
    ここでいう回答率とは、空でないコードを生成した設問の割合です。またコメントのみ生成した場合も回答したとみなします。
    内側のリストには、設問とそれに続く回答からなるコードスニペットが含まれています。
    設問と回答は3つのシングルクォートまたは3つのダブルクォートで区切られます。
    pass@KにおけるK通りのコードスニペットすべてが空のとき、その設問は無回答だと判定されます。
    引数:
    lst_lst_code_snippets (List[List[str]]): N件の設問に対するK通りのコードスニペット
    戻り値:
    float: 空でない回答をした設問の比率。
    """
    n_questions = len(lst_lst_code_snippets)
    n_no_answer = sum(map(if_no_answer, lst_lst_code_snippets))
    return 1.0 - n_no_answer / n_questions


if __name__ == "__main__":

    import io, json
    import argparse

    parser = argparse.ArgumentParser(description="Calculates answer ratio of (J)HumanEval task using generated outputs.")
    parser.add_argument("--generation_path", required=True, type=str, help="Path to the `generation_(j)humaneval.json` file.")
    parser.add_argument("--metrics_path", required=True, type=str, help="Path to the `metrics.json` file.")
    args = parser.parse_args()

    with io.open(args.generation_path, mode="r") as ifs:
        lst_lst_outputs = json.load(ifs)

    answer_ratio = calculate_answer_ratio(lst_lst_code_snippets=lst_lst_outputs)
    print(f"answer ratio: {answer_ratio:1.3f}")

    with io.open(args.metrics_path, mode="r") as ifs:
        metrics = json.load(ifs)
    metrics["humaneval"]["answer@10"] = answer_ratio

    with io.open(args.metrics_path, mode="w") as ofs:
        json.dump(metrics, ofs)
