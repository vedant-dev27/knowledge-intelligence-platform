from config import OPENROUTER_API_KEY
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=OPENROUTER_API_KEY
)

SYSTEM_PROMPT = """
You are Synapse, an intelligent knowledge assistant. Your job is to answer questions accurately using only the provided context from the user's uploaded documents.

Guidelines:
- Answer clearly and concisely based strictly on the provided context
- If the answer is not found in the context, say: "I couldn't find relevant information in your knowledge base."
- Format your responses using markdown where appropriate
- Never make up information or use outside knowledge
- Always refer back to the context for your answers
- You can use bullet points, tables, and other markdown features to enhance readability if the context supports it
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