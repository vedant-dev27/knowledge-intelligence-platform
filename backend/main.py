from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from services.embed_service import embed_message
from services.search_service import semantic_search
from services.llm_service import gen_ans
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatMessage(BaseModel):
    message: str

@app.post("/chat")
def receive_message(data: ChatMessage):
    embedded_message = embed_message(data.message)
    search_results = semantic_search(embedded_message)
    gem = gen_ans(search_results, data.message)
    return {"response": gem}