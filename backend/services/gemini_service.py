from config import GEMINI_API_KEY
from google import genai

client = genai.Client(api_key=GEMINI_API_KEY)

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
{question}"""

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt,
        config=genai.types.GenerateContentConfig(
            system_instruction=SYSTEM_PROMPT,
        ),
    )

    return str(response.text)