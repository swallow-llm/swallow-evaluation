import random
import re

import datasets


def preprocess(text):
    if text is None:
        return " "
    text = text.strip()
    text = text.replace(" [title]", ". ")
    text = re.sub("\\[.*?\\]", "", text)
    text = text.replace("  ", " ")
    return text


def doc_to_text(doc: dict) -> str:
    """
    Returns a zero-shot chain-of-thought prompt. This is identical to the Meta's user instruction (although they apply chat template to the user instruction).
    Ref. https://huggingface.co/datasets/meta-llama/Llama-3.1-8B-Instruct-evals/viewer/Llama-3.1-8B-Instruct-evals__gpqa__details
    """
    # Uncomment the following line to use instructions (works well with "model voice")

    PROMPT = """
Given the following question and four candidate answers (A, B, C and D), choose the best answer.

Question: {Question}
A. {choice1}
B. {choice2}
C. {choice3}
D. {choice4}

- For simple problems:
Directly provide the answer with minimal explanation.

- For complex problems:
Use this step-by-step format:
## Step 1: [Concise description]
[Brief explanation]
## Step 2: [Concise description]
[Brief explanation]

Regardless of the approach, always conclude with:
The best answer is [the_answer_letter].
where the [the_answer_letter] is one of A, B, C or D.

Let's think step by step.""".strip()

    text = PROMPT.format(**doc)

    return text


def process_docs(dataset: datasets.Dataset) -> datasets.Dataset:
    """
    Returns a dictionary that is compatible with zero-shot chain-of-thought prompt template.
    Note that "answer" is single alphabet; A, B, C, or D. Parenthesis isn't applied anymore.
    Ref. https://huggingface.co/datasets/meta-llama/Llama-3.1-8B-Instruct-evals/viewer/Llama-3.1-8B-Instruct-evals__gpqa__details
    """

    def _process_doc(doc):
        choices = [
            preprocess(doc["Incorrect Answer 1"]),
            preprocess(doc["Incorrect Answer 2"]),
            preprocess(doc["Incorrect Answer 3"]),
            preprocess(doc["Correct Answer"]),
        ]

        random.shuffle(choices)
        correct_answer_index = choices.index(preprocess(doc["Correct Answer"]))

        out_doc = {
            "choice1": choices[0],
            "choice2": choices[1],
            "choice3": choices[2],
            "choice4": choices[3],
            "choices": [choices[0], choices[1], choices[2], choices[3]],
            "answer": f"{chr(65 + correct_answer_index)}",  # 括弧はつけません
        }
        return out_doc

    return dataset.map(_process_doc)
