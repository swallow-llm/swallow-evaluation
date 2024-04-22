import json
import argparse
import csv
import os

def get_tasks(raw_path: str):
    
    jmmlu_files = [f for f in os.listdir(raw_path) if f.startswith("jmmlu") and f.endswith(".csv")]
    ques2task = {}
    
    for file in jmmlu_files:
        curr_task = file.replace(".csv", "").replace("jmmlu_", "")
        with open(os.path.join(raw_path, file), newline="", encoding="utf-8-sig") as csvfile:
            data_reader = csv.reader(csvfile, quoting=csv.QUOTE_ALL)
            for row in data_reader:
                    ques = row[0].strip().replace('\r', '')
                    ques2task[ques] = curr_task
                
    return ques2task

def get_statistics(pred_path: str, ques2task: dict):
    
    all_tasks = set([v for v in ques2task.values()])
    pred_data = json.load(open(pred_path))
    
    jmmlu_pred_data = pred_data["outputs"]["jmmlu"]
    
    # record the correct/incorrect predictions for each task
    task_preds = {t: {"true": 0, "false": 0} for t in all_tasks}
    
    for data in jmmlu_pred_data:
        curr_input = data["input"]
        curr_question = curr_input.split("選択肢：")[0].replace("質問：", "").strip()
        curr_task = ques2task[curr_question]
        
        if data["gold"] == data["pred"]:
            task_preds[curr_task]["true"] += 1
        else:
            task_preds[curr_task]["false"] += 1
    
    # compute exact match for each task
    results = {}
    all_true = 0
    all_false = 0
    for t in task_preds:
        results[f"jmmlu_{t}_exact_match"] = task_preds[t]["true"] / (task_preds[t]["true"] + task_preds[t]["false"])
        all_true += task_preds[t]["true"]
        all_false += task_preds[t]["false"]
        
    results["jmmlu"] = all_true / (all_true + all_false)
    
    return results
    

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser()
    parser.add_argument("--gold_path", type=str, default="llm-jp-eval/dataset/raw_files/")
    parser.add_argument("--pred_path", type=str)
    
    args = parser.parse_args()
    gold_path = args.gold_path
    pred_path = args.pred_path
    
    jmmlu_ques2task = get_tasks(gold_path)
    results = get_statistics(pred_path, jmmlu_ques2task)
    
    save_name = pred_path.replace(".json", "")
    save_name = f"{save_name}_per_task.json"
    with open(save_name, "w") as wf:
        json.dump(results, wf)
        