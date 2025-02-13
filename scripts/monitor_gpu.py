import subprocess
import time
import sys
import os
import csv
import argparse


def get_gpu_memory():
    """nvidia-smiを使ってGPUメモリ使用量を取得"""
    result = subprocess.run(
        ["nvidia-smi", "--query-gpu=memory.used,memory.total", "--format=csv,nounits,noheader"],
        stdout=subprocess.PIPE,
        text=True
    )
    gpu_stats = result.stdout.strip().split("\n")
    gpu_usage = [tuple(map(int, gpu.split(", "))) for gpu in gpu_stats]
    return gpu_usage

def write_csv_header(file_path, num_gpus):
    """CSVファイルにヘッダーを書き込む"""
    with open(file_path, mode="w", newline="") as f:
        writer = csv.writer(f)
        header = ["timestamp"]
        for i in range(num_gpus):
            header.append(f"GPU{i}_used")
            header.append(f"GPU{i}_total")
        writer.writerow(header)

def log_gpu_usage(output_path):
    """GPUの使用状況を定期的に標準出力とCSVに記録"""
    # 最初にGPU数を取得して、CSVヘッダーを書き込む（ファイルが存在しない場合）
    gpu_usage = get_gpu_memory()
    num_gpus = len(gpu_usage)
    if not os.path.exists(output_path):
        write_csv_header(output_path, num_gpus)
        
    while True:
        gpu_usage = get_gpu_memory()
        log_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
        # 標準出力用のログ
        log_entry = f"{log_time} " + " ".join([f"GPU{i}: {used}/{total}MB" for i, (used, total) in enumerate(gpu_usage)])
        print(log_entry, flush=True)
        
        # CSVに追記する行を作成
        row = [log_time]
        for used, total in gpu_usage:
            row.extend([used, total])
        with open(output_path, mode="a", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(row)
        
        time.sleep(60)  # 1分ごとに記録

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output_path", required=True)
    args = parser.parse_args()
    try:
        log_gpu_usage(args.output_path)
    except KeyboardInterrupt:
        print("GPUモニタリングを終了します。", file=sys.stderr)
        sys.exit(0)
