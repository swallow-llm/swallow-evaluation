import json
import argparse
import csv
import os

SUBJECTS = {
    "abstract_algebra": "stem",
    "anatomy": "stem",
    "astronomy": "stem",
    "business_ethics": "other",
    "clinical_knowledge": "other",
    "college_biology": "stem",
    "college_chemistry": "stem",
    "college_computer_science": "stem",
    "college_mathematics": "stem",
    "college_medicine": "other",
    "college_physics": "stem",
    "computer_security": "stem",
    "conceptual_physics": "stem",
    "econometrics": "social_sciences",
    "electrical_engineering": "stem",
    "elementary_mathematics": "stem",
    "formal_logic": "humanities",
    "global_facts": "other",
    "high_school_biology": "stem",
    "high_school_chemistry": "stem",
    "high_school_computer_science": "stem",
    "high_school_european_history": "humanities",
    "high_school_geography": "social_sciences",
    "high_school_government_and_politics": "social_sciences",
    "high_school_macroeconomics": "social_sciences",
    "high_school_mathematics": "stem",
    "high_school_microeconomics": "social_sciences",
    "high_school_physics": "stem",
    "high_school_psychology": "social_sciences",
    "high_school_statistics": "stem",
    "japanese_history": "humanities",
    "world_history": "humanities",
    "human_aging": "other",
    "human_sexuality": "social_sciences",
    "international_law": "humanities",
    "jurisprudence": "humanities",
    "logical_fallacies": "humanities",
    "machine_learning": "stem",
    "management": "other",
    "marketing": "other",
    "medical_genetics": "other",
    "miscellaneous": "other",
    "moral_disputes": "humanities",
    "moral_scenarios": "humanities",
    "nutrition": "other",
    "philosophy": "humanities",
    "prehistory": "humanities",
    "professional_accounting": "other",
    "professional_law": "humanities",
    "professional_medicine": "other",
    "professional_psychology": "social_sciences",
    "public_relations": "social_sciences",
    "security_studies": "social_sciences",
    "sociology": "social_sciences",
    "us_foreign_policy": "social_sciences",
    "virology": "other",
    "world_religions": "humanities",
}


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


def get_subject_statistics(preds: dict):
    
    all_subjs = set(SUBJECTS.values())
    subj_preds = {s: {"true": 0, "false": 0} for s in all_subjs}
    subj2categories = {f"jmmlu_{s}":[] for s in all_subjs}
    
    for t in preds:
        curr_subj = SUBJECTS[t]
        subj2categories[f"jmmlu_{curr_subj}"].append(f"jmmlu_{t}")
        subj_preds[curr_subj]["true"] += preds[t]["true"]
        subj_preds[curr_subj]["false"] += preds[t]["false"]
        
    
    # assert all categories have been assigned to one subject
    assert len(sum([subj2categories[s] for s in subj2categories],[])) == len(preds)
    
    return subj_preds, subj2categories
    
    
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
    subj_preds, sub2categories = get_subject_statistics(task_preds)


    results = {"results": {}, "groups": {}, "group_subtasks": sub2categories}
    all_true = 0
    all_false = 0
    for t in task_preds:
        results["results"][f"jmmlu_{t}"] = task_preds[t]["true"] / (task_preds[t]["true"] + task_preds[t]["false"])
        all_true += task_preds[t]["true"]
        all_false += task_preds[t]["false"]
    for s in subj_preds:
        results["results"][f"jmmlu_{s}"] = subj_preds[s]["true"] / (subj_preds[s]["true"] + subj_preds[s]["false"])    
        results["groups"][f"jmmlu_{s}"] = results["results"][f"jmmlu_{s}"]
    
    results["results"]["jmmlu"] = all_true / (all_true + all_false)
    results["groups"]["jmmlu"] = results["results"]["jmmlu"]
    
    # assert the grouped accuracy is computed from the micro average of all instances
    for s in subj_preds:
        true = sum([task_preds[t.replace("jmmlu_", "")]["true"] for t in sub2categories[f"jmmlu_{s}"]])
        false = sum([task_preds[t.replace("jmmlu_", "")]["false"] for t in sub2categories[f"jmmlu_{s}"]])
        assert true / (true + false) == results["results"][f"jmmlu_{s}"]
    
    return results
    

if __name__ == "__main__":
    
    parser = argparse.ArgumentParser()
    parser.add_argument("--gold_path", type=str, default="llm-jp-eval/dataset/raw_files/")
    parser.add_argument("--pred_path", type=str)
    
    args = parser.parse_args()
    gold_path = args.gold_path
    pred_path = args.pred_path
    
    pred_files = [p for p in os.listdir(pred_path) if not p.endswith("_per_task.json")]
    assert len(pred_files) == 1
    
    pred_file = pred_files[0]
    pred_file = os.path.join(pred_path, pred_file)
    jmmlu_ques2task = get_tasks(gold_path)
    results = get_statistics(pred_file, jmmlu_ques2task)
    

    save_name = pred_file.replace(".json", "")
    save_name = f"{save_name}_per_task.json"
    with open(save_name, "w") as wf:
        json.dump(results, wf, indent=2)
        