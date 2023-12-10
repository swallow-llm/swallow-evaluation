#!/usr/bin/env python
# -*- coding:utf-8 -*-

from typing import Dict, Any, List
import json
import argparse
from collections import Counter

def load_data(input_path) -> Dict[str, Any]:
    with open(input_path, 'r') as file:
        data = json.load(file)
    return data

def calculate_accuracy(preds: List[str], golds: List[str]) -> float:
    correct = sum(p == g for p, g in zip(preds, golds))
    return correct / len(golds)

def calculate_balanced_accuracy(preds: List[str], golds: List[str]) -> float:
    class_counts = Counter(golds)
    class_correct = Counter()
    num_classes = len(class_counts)

    for pred, gold in zip(preds, golds):
        if pred == gold:
            class_correct[gold] += 1

    lst_class_accuracy = [class_correct[class_name] / num_gold for class_name, num_gold in class_counts.items()]
    balanced_acc = sum(lst_class_accuracy) / num_classes
    return balanced_acc

def calculate_metrics(dict_records: Dict[str, Any], dataset_names: List[str], debug: bool = False) -> Dict[str, float]:
    results = {}
    macro_accuracy = 0.0
    macro_balanced_accuracy = 0.0
    for dataset_name in dataset_names:
        lst_preds = [item['pred'] for item in dict_records[dataset_name]]
        lst_golds = [item['gold'] for item in dict_records[dataset_name]]

        class_num_preds, class_num_golds = Counter(lst_preds), Counter(lst_golds)
        acc = calculate_accuracy(lst_preds, lst_golds)
        balanced_acc = calculate_balanced_accuracy(lst_preds, lst_golds)

        num_classes = len(set(lst_golds))
        results[f"{dataset_name}_num_classes"] = num_classes
        results[f"{dataset_name}_num_pred_classes"] = len(class_num_preds)
        results[f"{dataset_name}_is_unsolved"] = len(class_num_preds) == 1
        results[f"{dataset_name}_accuracy"] = acc
        results[f"{dataset_name}_balanced_accuracy"] = balanced_acc
        results[f"{dataset_name}_balanced_accuracy_random_baseline"] = 1 / num_classes
        
        macro_accuracy += acc
        macro_balanced_accuracy += balanced_acc
        
        if debug:
            results[f"{dataset_name}_num_golds"] = class_num_golds
            results[f"{dataset_name}_num_preds"] = class_num_preds
    
    results["macro_accuracy"] = macro_accuracy / len(dataset_names)
    results["macro_balanced_accuracy"] = macro_balanced_accuracy / len(dataset_names)
    
    return results

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', required=True, type=str, help='Path to the JSON file exported by llm-jp-eval framework.')
    parser.add_argument('--datasets', required=False, type=str, default="jamp,janli,jnli,jsem,jsick", help="Abbreviations of the target evaluation dataset names. DEFAULT: jamp,janli,jnli,jsem,jsick")
    parser.add_argument('--debug', action="store_true", help="Also output number of correct / predicted number of examples for each class.")
    args = parser.parse_args()

    dict_data = load_data(args.input)
    dict_results = calculate_metrics(dict_records=dict_data, dataset_names=args.datasets.split(","), debug=args.debug)
    dict_results["input_path"] = args.input
    
    print(json.dumps(dict_results, ensure_ascii=False))

if __name__ == "__main__":
    main()