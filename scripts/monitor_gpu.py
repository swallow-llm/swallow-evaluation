import subprocess
import time
import sys
import signal
import os

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

def log_gpu_usage():
    """GPUの使用状況を定期的に標準出力に表示"""
    while True:
        gpu_usage = get_gpu_memory()
        log_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
        log_entry = f"{log_time} " + " ".join([f"GPU{i}: {used}/{total}MB" for i, (used, total) in enumerate(gpu_usage)])
        print(log_entry, flush=True)  # 標準出力に出力
        time.sleep(60)  # 1分ごとに記録

if __name__ == "__main__":
    try:
        log_gpu_usage()
    except KeyboardInterrupt:
        print("GPUモニタリングを終了します。", file=sys.stderr)
        sys.exit(0)