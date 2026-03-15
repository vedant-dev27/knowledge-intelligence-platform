from fastapi import FastAPI,Request,HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from services.embed_service import embed_message
from services.search_service import semantic_search
from services.llm_service import gen_ans
from services.auth_service import registerUser, loginUser,verifyUser

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

class AuthRequest(BaseModel):
    uid: str
    pwd: str

@app.post("/chat")
def receiveRessage(data: ChatMessage):
    embedded_message = embed_message(data.message)
    search_results = semantic_search(embedded_message)
    gem = gen_ans(search_results, data.message)
    return {"response": gem}

@app.post("/register")
def register(req: AuthRequest):
    success = registerUser(req.uid, req.pwd)
    if success:
        return {"response": True, "message": "User registered"}
    return {"response": False, "message": "Username already exists"}

@app.post("/login")
def login_endpoint(req: AuthRequest):
    return loginUser(req.uid, req.pwd)

@app.get("/auth/verify")
def verify_token(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or malformed token")
    
    token = auth_header.split(" ")[1]
    result = verifyUser(token)
    
    if not result["valid"]:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    
    return {"uid": result["uid"]}