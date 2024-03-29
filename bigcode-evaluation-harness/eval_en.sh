model_name=$1

docker run -v /home/ohi-m/jalm-evaluation-private/results/${model_name}/en/humaneval/generation_humaneval.json:/app/generations_py.json -it evaluation-harness python3 main.py --model ${model_name} --tasks humaneval --load_generations_path /app/generations_py.json --allow_code_execution --n_samples 10
