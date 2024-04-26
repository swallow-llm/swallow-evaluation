#!/usr/bin/env python
# -*- coding:utf-8 -*-

import re
from typing import Dict, Any, List
import json
import argparse
import os
import pandas as pd
from collections import defaultdict
from functools import reduce
from operator import getitem


# TODO: Hardcorded subtasks columns map for averaging the scores
SUBTASKS_COLUMNS_MAP = {
    "MC": ["jemhopqa"],
    "NLI": ["jamp (NLI)", "janli (NLI)", "jnli", "jsem", "jsick (NLI)"],
    "QA": ["jcommonsenseqa", "niilc"],
    "RC": ["jsquad"],
}


def load_json(input_path:str) -> Dict[str, Any]:
    with open(input_path, 'r') as file:
        data = json.load(file)
    return data


def get_nested_dict_value(input_path:str, key:str) -> float:
    # get value from nested dictionary by key string
    # e.g. get_dict_value(data, 'key1.key2.key3')
    d = load_json(input_path)
    keys = key.split('.')
    try:
        metric = float(reduce(getitem, keys, d))
    except KeyError:
        print(f"Key not found: {key}")
        return -1.0

    return metric


def get_average_score(input_path:str, keys: List[str]) -> float:
    """get average score from multiple keys"""
    scores = [get_nested_dict_value(input_path, key) for key in keys]
    
    # if scores has -1.0, return -1.0 
    # because some of the subtasks are not evaluated
    if -1.0 in scores:
        return -1.0
    
    return sum(scores) / len(scores)


def aggregate_results(model: str) -> Dict[str, float]:
    """load all results of the model and aggregate the scores into a single dictionary"""
    column_path_key_csv = pd.read_csv(os.path.join(os.getcwd(), "scripts", "column-path-key.csv"))
    task_key_map = {
        k: v.replace("MODEL_NAME", model.replace("/", "_")) for k, v in column_path_key_csv[["column", "key"]].values
    }
    
    results = {}
    overall = []
    result_root_dir = os.path.join(os.getcwd(), "results", model)
    
    for _, row in column_path_key_csv.iterrows():
        column, path, _, max_score = row
        key = task_key_map[column]
        input_path = os.path.join(result_root_dir, path)
        
        # defalut value if the column is empty
        metric = -1.0
        
        # error handling if the file is not found
        if not os.path.exists(input_path):
            print(f"Column: {column} is empty")
            print(f"File not found: {input_path}")
            results[column] = metric
            overall.append(metric)
            continue
        
        if column in SUBTASKS_COLUMNS_MAP.keys():
            subtasks = SUBTASKS_COLUMNS_MAP[column]
            keys_subtasks = [task_key_map[subtask] for subtask in subtasks]
            metric = get_average_score(input_path, keys_subtasks)
        else:
            metric = get_nested_dict_value(input_path, key)
        
        # Normalize the score using predefined max_score
        metric = metric / max_score
        
        results[column] = metric
        overall.append(metric)
    
    json_result = {
        "model": model,
        "result": results,
        "overall": ','.join(map(str, overall)),
        "tasks": list(results.keys())
    }
    
    json.dump(json_result, open(f"{result_root_dir}/aggregated_result.json", "w"), indent=2, ensure_ascii=False)
    
    return results


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--model', required=True, type=str, help='Model name to aggregate')
    args = parser.parse_args()
    aggregate_results(args.model)

if __name__ == "__main__":
    main()