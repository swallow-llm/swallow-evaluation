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

python -m venv .venv_harness_jp
conda deactivate
conda deactivate
source .venv_harness_jp/bin/activate

cd lm-evaluation-harness-jp
pip install --upgrade pip
pip install -e ".[ja]"
pip install nagisa
pip install sacrebleu
pip install sentencepiece
pip install protobuf