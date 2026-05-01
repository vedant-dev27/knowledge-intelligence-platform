from config import OPENROUTER_API_KEY
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=OPENROUTER_API_KEY
)

SYSTEM_PROMPT = """
You are Synapse, an intelligent knowledge assistant. Answer the user's question using the provided context from their uploaded documents.

Follow these rules strictly:
- If the context directly answers the question, answer clearly and concisely
- If the context contains partial or related information, use it to construct the best possible answer and mention it is based on available context
- If the context has absolutely zero relevance to the question, only then say: "I couldn't find relevant information in your knowledge base."
- Never say the context is insufficient if there is ANY related information present
- Always be helpful, frame partial information as useful insights
- Use markdown formatting for clarity
- Never use outside knowledge, only what is in the context
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