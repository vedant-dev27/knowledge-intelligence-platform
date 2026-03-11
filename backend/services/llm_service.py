from config import OPENROUTER_API_KEY
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=OPENROUTER_API_KEY
)

SYSTEM_PROMPT = """
You are an AI assistant that answers questions using the provided context.
Use ONLY the information from the context to answer the question.
If the answer cannot be found in the context, respond with:
"I could not find the answer in the knowledge base."
"""

def gen_ans(context: str, question: str) -> str:

    prompt = f"""Context:
{context}

Question:
{question}
"""

    response = client.chat.completions.create(
        model="mistralai/mistral-nemo",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": prompt}
        ],
        temperature=0
    )
    print(response.choices[0].message.content)
    return response.choices[0].message.content