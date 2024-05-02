"""
Usage:
python3 show_result.py --mode [single|pairwise-baseline|pairwise-all]
"""

import argparse
import pandas as pd
import json
import numpy as np


CATEGORIES = ["Coding", "Extraction", "Humanities", "Math", "Reasoning", "Roleplay", "STEM", "Writing"]
CATEGORIES_ordered = ["Writing", "Roleplay", "Reasoning", "Math", "Coding", "Extraction", "STEM", "Humanities"]


def calculate_averages(scores):
    # scores: [N, T], N: 設問数, T: 回答数(5)
    scores = np.array(list(scores))
    valid_scores = scores != -1
    valid_count = valid_scores.sum(axis=0)
    question_mean = np.where(valid_scores, scores, 0).sum(axis=0) / valid_count
    mu = np.mean(question_mean)
    sigma = np.std(question_mean, ddof=1)
    return mu, sigma

def display_result_single(args):
    if args.input_file is None:
        if args.azure:
            input_file = f"data/{args.bench_name}/model_judgment/{args.judge_model}_single_azure.jsonl"
        else:
            input_file = f"data/{args.bench_name}/model_judgment/{args.judge_model}_single.jsonl"
    else:
        input_file = args.input_file

    print(f"Input file: {input_file}")
    df_all = pd.read_json(input_file, lines=True)
    df_all["category"] = df_all["question_id"].apply(lambda x: CATEGORIES[(x - 81) // 10])
    df = df_all[["model", "score", "turn", "category"]]

    if args.model_list is not None:
        df = df[df["model"].isin(args.model_list)]

    result = dict()
    for model_id in args.model_list:
        result[model_id] = dict()

    def score_category(category):
        if category != "overall":
            df_cat = df[df["category"] == category][["model", "score", "turn"]]
        else:
            df_cat = df[["model", "score", "turn"]]
        df_1 = df_cat[df_cat["turn"] == 1].groupby("model")["score"].apply(calculate_averages)
        print(df_1)
        for model_id in args.model_list:
            result[model_id][category] = dict()
            result[model_id][category]["first_turn"] = dict()
            result[model_id][category]["first_turn"]["score"] = float(df_1.loc[model_id][0])
            result[model_id][category]["first_turn"]["new_variance"] = float(df_1.loc[model_id][1])
        if args.bench_name == "mt_bench" or args.bench_name == "japanese_mt_bench":
            df_2 = df_cat[df_cat["turn"] == 2].groupby("model")["score"].apply(calculate_averages)
            print(df_2)
            for model_id in args.model_list:
                result[model_id][category]["second_turn"] = dict()
                result[model_id][category]["second_turn"]["score"] = float(df_2.loc[model_id][0])
                result[model_id][category]["second_turn"]["new_variance"] = float(df_2.loc[model_id][1])
            df_3 = df_cat.groupby("model")["score"].apply(calculate_averages)
            print(df_3)
            for model_id in args.model_list:
                result[model_id][category]["average"] = dict()
                result[model_id][category]["average"]["score"] = float(df_3.loc[model_id][0])
                result[model_id][category]["average"]["new_variance"] = float(df_3.loc[model_id][1])

    for category in ["overall"] + CATEGORIES_ordered:
        score_category(category)

    # 各モデルの各カテゴリのaverage scoreをカンマ区切りで"result"に文字列として追加
    for model_id in args.model_list:
        result[model_id]["result"] = dict()
        for turn in ["first_turn", "second_turn", "average"]:
            result[model_id]["result"][turn] = dict()
            result[model_id]["result"][turn]["score"] = ",".join(
                [f"{(result[model_id][category][turn]['score'] / 10):.4f}" for category in ["overall"] + CATEGORIES_ordered]
            )
            result[model_id]["result"][turn]["new_variance"] = ",".join(
                [f"{result[model_id][category][turn]['new_variance']:.4f}" for category in ["overall"] + CATEGORIES_ordered]
            )

    if args.output_file is not None:
        with open(args.output_file, "w") as f:
            json.dump(result, f, indent=4)


def display_result_pairwise(args):
    if args.input_file is None:
        if args.azure:
            input_file = f"data/{args.bench_name}/model_judgment/{args.judge_model}_pair_azure.jsonl"
        else:
            input_file = f"data/{args.bench_name}/model_judgment/{args.judge_model}_pair.jsonl"
    else:
        input_file = args.input_file

    print(f"Input file: {input_file}")
    df_all = pd.read_json(input_file, lines=True)
    df_all = df_all[(df_all["g1_winner"] != "error") & (df_all["g2_winner"] != "error")]

    model_list = df_all["model_1"].unique().tolist() + df_all["model_2"].unique().tolist()
    model_list = list(set(model_list))

    list_res = []
    # traverse df row by row
    for index, row in df_all.iterrows():
        if args.model_list is not None and row["model_1"] not in args.model_list:
            continue
        if args.baseline_model is not None:
            if args.baseline_model not in [row["model_1"], row["model_2"]]:
                continue
        if row["g1_winner"] == "tie" or row["g1_winner"] != row["g2_winner"]:
            list_res.append({"model": row["model_1"], "win": 0, "loss": 0, "tie": 1})
            list_res.append({"model": row["model_2"], "win": 0, "loss": 0, "tie": 1})
        else:
            if row["g1_winner"] == "model_1":
                winner = row["model_1"]
                loser = row["model_2"]
            else:
                winner = row["model_2"]
                loser = row["model_1"]
            list_res.append({"model": winner, "win": 1, "loss": 0, "tie": 0})
            list_res.append({"model": loser, "win": 0, "loss": 1, "tie": 0})

    df = pd.DataFrame(list_res)
    df = df.groupby(["model"]).sum()

    # remove baseline model
    if args.baseline_model is not None:
        df = df[df.index != args.baseline_model]
    # add win rate
    df["win_rate"] = df["win"] / (df["win"] + df["loss"] + df["tie"])
    df["loss_rate"] = df["loss"] / (df["win"] + df["loss"] + df["tie"])
    # each tie counts as 0.5 win + 0.5 loss
    df["win_rate_adjusted"] = (df["win"] + 0.5 * df["tie"]) / (df["win"] + df["loss"] + df["tie"])
    print(df.sort_values(by="win_rate_adjusted", ascending=False))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--bench-name", type=str, default="mt_bench")
    parser.add_argument("--input-file", type=str)
    parser.add_argument("--judge-model", type=str, default="gpt-4")
    parser.add_argument("--output-file", type=str)
    parser.add_argument("--baseline-model", type=str, default="gpt-3.5-turbo")
    parser.add_argument(
        "--model-list",
        type=str,
        nargs="+",
        default=None,
        help="A list of models to be evaluated",
    )
    parser.add_argument(
        "--mode",
        type=str,
        default="single",
        choices=["pairwise-baseline", "pairwise-all", "single"],
        help=(
            "Evaluation mode. "
            "`pairwise-baseline` runs pairwise comparision against a baseline. "
            "`pairwise-all` runs pairwise comparision between all pairs. "
            "`single` runs single answer grading."
        ),
    )
    parser.add_argument(
        "--azure",
        action="store_true",
        help="Did you use Azure API instead of openai when generating the judgment?",
        default=True,
    )
    args = parser.parse_args()

    args.model_list = [model_name.replace("/", "_") for model_name in args.model_list]

    if args.mode == "single":
        display_result_func = display_result_single
    else:
        if args.mode == "pairwise-all":
            args.baseline_model = None
        display_result_func = display_result_pairwise

    print(f"Mode: {args.mode}")
    display_result_func(args)
