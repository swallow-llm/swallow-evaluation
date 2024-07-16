#!/bin/bash
#$ -cwd

#$ -l gpu_h=1
#$ -l h_rt=24:00:00

repo_path=$1

module load miniconda
eval "$(/apps/t4/rhel9/free/miniconda/24.1.2/bin/conda shell.bash hook)"
module load cuda/12.1.0
module load cudnn/9.0.0
conda activate python_310
cd $repo_path

python -m venv .venv_fastchat
conda deactivate
conda deactivate
source .venv_fastchat/bin/activate

cd fastchat
pip install --upgrade pip
pip install python-dotenv pandas
pip install -e ".[model_worker,llm_judge]"