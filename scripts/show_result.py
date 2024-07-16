import os
import json
import argparse
from unittest import result

def _show_tasks(format, tasks):
    # load result_json
    if format == 'csv':
        print('model,' + ','.join(tasks))
    elif format == 'markdown':
        # print header
        print('|model|' + '|'.join(tasks) + '|')
        print('|---|' + '|'.join(['---']*len(tasks)) + '|')
    else:
        # raise unimplemented error
        raise NotImplementedError('format is not implemented')
        
def _show_results(args, result_paths, tasks):
    format, digit = args.format, args.digits
    # print model_name and result of each task in a single line
    for result_path in result_paths:
        with open(result_path, 'r') as f:
            result_json = json.load(f)
        model = result_json['model']
        results = result_json['result']
        
        # 小数第digit位まで表示
        if digit != -1:
            results = {task: round(results[task], digit) for task in tasks}
        
        if format == 'csv':
            print(model + ',' + ','.join([str(results[task]) for task in tasks]))
        elif format == 'markdown':
            print(f'|{model}|' + '|'.join([str(results[task]) for task in tasks]) + '|')
        else:
            # raise unimplemented error
            raise NotImplementedError('format is not implemented')

def show_result(args):
    with open (args.model_list, 'r') as f:
        model_list = f.read().split('\n')
    # get result_paths with query. 
    # result file is named 'aggregated_result.json'
    root_dir = os.getcwd()
    search_dir = os.path.join(root_dir, 'results')
    result_paths = [os.path.join(search_dir, model, 'aggregated_result.json') for model in model_list]

    # load tasks
    if args.tasks is None:
        with open(result_paths[0], 'r') as f:
            result_json = json.load(f)
        tasks = result_json['tasks']
    else:
        tasks = args.tasks.split(',')

    # show results
    _show_tasks(args.format, tasks)
    _show_results(args, result_paths, tasks)
    

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--model-list', type=str, default='tmp/model_list', help='Text file of model list. A single model name per a line.')
    parser.add_argument('--format', type=str, choices=['csv', 'markdown'], default='csv')
    parser.add_argument('--digits', type=int, default=-1)
    parser.add_argument('--tasks', type=str, default=None)
    return parser.parse_args()

def main():
    args = parse_args()
    show_result(args)


if __name__ == '__main__':
    main()