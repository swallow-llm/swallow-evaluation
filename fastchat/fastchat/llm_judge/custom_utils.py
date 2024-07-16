import json
import sys
from typing import List, Dict, Any
from collections import defaultdict


CATEGORIES = ["Coding", "Extraction", "Humanities", "Math", "Reasoning", "Roleplay", "STEM", "Writing"]
CATEGORIES_ordered = ["Writing", "Roleplay", "Reasoning", "Math", "Coding", "Extraction", "STEM", "Humanities"]

# question_id を category に変換する関数
def map_question_to_category(question_id: int) -> str:
    # IDが1以上であることを確認
    if question_id < 1:
        raise ValueError("質問IDは1以上でなければなりません。")

    # カテゴリの数
    num_categories = len(CATEGORIES)
    # カテゴリ別設問数
    questions_per_category = 10

    # カテゴリインデックスを計算
    category_index = (question_id - 1) // questions_per_category % num_categories

    return CATEGORIES[category_index]


# 日本語文字か否かを判定する関数
def is_japanese_char(ch):
    # Hiragana
    if "\u3041" <= ch <= "\u309f":
        return True
    # Katakana
    if "\u30a1" <= ch <= "\u30ff":
        return True
    # Kanji (CJK Unified Ideographs excl. Extenson A-I)
    if "\u4e00" <= ch <= "\u9fff":
        return True
    # Full-width characters
    if "\uff01" <= ch <= "\uff5e":
        return True
    # Japanese punctuation and symbols
    # https://qiita.com/YusukeHirao/items/099ab93bdbf47f0d7a02
    if ("\u3000" <= ch <= "\u3036") or (ch == "\u30fb") or (ch == "\uff5e"):
        return True
    return False


# テキスト中の日本語文字の割合を計算する関数
def count_japanese_chars(text: str) -> int:
    num_japanese_chars = sum(1 for ch in text if is_japanese_char(ch))
    return num_japanese_chars


def safe_divide(numerator: int, denominator: int) -> float:
    if denominator == 0:
        return 0.0
    else:
        return numerator / denominator


def calculate_japanese_character_ratio(lst_mtbench_model_answers: List[Dict[str, Any]]):
    """
    MT-Bench応答文に含まれる，ひらがな・カタカナ・漢字の割合を計算します．
    カテゴリ別 (coding, math, ...) およびカテゴリ全体の9種類を計算します．
    値はマイクロ平均です．
    つまり，マルチターン・複数回応答文生成・複数の設問で得られたすべての応答文を連結して割合を計算しています．

    Args:
        lst_mtbench_model_answers (List[Dict[str, Any]]): gen_model_answer.pyが出力した応答文

    Returns:
        {"ja_char_ratio-{カテゴリ名 または ALL}": <ひらがな・カタカナ・漢字の割合>}
    """

    total_chars = 0
    total_japanese_chars = 0
    category_counts = defaultdict(lambda: defaultdict(int))

    # まずひらがな・カタカナ・漢字の文字数を数える
    for mtbench_answer in lst_mtbench_model_answers:
        question_id = mtbench_answer.get("question_id", 0)
        question_category = map_question_to_category(question_id=question_id)

        for choice in mtbench_answer.get("choices", []):
            for response in choice.get("turns", []):
                num_chars = len(response)
                num_ja_chars = count_japanese_chars(response)

                total_chars += num_chars
                total_japanese_chars += num_ja_chars
                category_counts[question_category]["total_chars"] += num_chars
                category_counts[question_category]["japanese_chars"] += num_ja_chars

    # 次にひらがな・カタカナ・漢字の文字数の割合のマイクロ平均を計算する
    results = {}
    for category_name, dict_char_counts in category_counts.items():
        num = dict_char_counts["japanese_chars"]
        denom = dict_char_counts["total_chars"]
        results[category_name] = safe_divide(numerator=num, denominator=denom)
    results["overall"] = safe_divide(numerator=total_japanese_chars, denominator=total_chars)

    return results


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python custom_utils.py {gen_model_answer.pyが出力したjsonlファイル}")
        sys.exit(1)

    input_file_path = sys.argv[1]
    lst_mtbench_model_answers = []

    with open(input_file_path, mode="r", encoding="utf-8") as ifs:
        for line in ifs:
            record = json.loads(line.strip())
            lst_mtbench_model_answers.append(record)

    model_id = lst_mtbench_model_answers[0].get("model_id", None)
    dict_ja_char_ratio = calculate_japanese_character_ratio(lst_mtbench_model_answers=lst_mtbench_model_answers)
    dict_ja_char_ratio["model_id"] = model_id

    print(json.dumps(dict_ja_char_ratio, ensure_ascii=False, indent=4))
