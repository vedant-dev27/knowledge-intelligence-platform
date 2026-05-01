from fastapi import FastAPI, Request, HTTPException, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from services.embed_service import embed_message
from services.search_service import semantic_search
from services.llm_service import gen_ans
from services.auth_service import registerUser, loginUser, verifyUser
from services.upload_service import save_file


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


class RegisterRequest(BaseModel):
    name: str
    uid: str
    pwd: str
    role: str


class LoginRequest(BaseModel):
    uid: str
    pwd: str


def get_current_user(request: Request):
    auth_header = request.headers.get("Authorization")

    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or malformed token")

    token = auth_header.split(" ")[1]
    result = verifyUser(token)

    if not result["valid"]:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    return result


@app.post("/chat")
def receive_message(data: ChatMessage, request: Request):
    user = get_current_user(request)

    embedded_message = embed_message(data.message)

    search_results = semantic_search(
        embedded_message,
        user_id=user["uid"]
    )

    gem = gen_ans(search_results, data.message)

    return {"response": gem}


@app.post("/register")
def register(req: RegisterRequest):
    role = req.role if req.role else "intern"

    success = registerUser(
        req.name,
        req.uid,
        req.pwd,
        role
    )

    return {
        "response": success,
        "message": "User registered" if success else "Username already exists"
    }


@app.post("/login")
def login_endpoint(req: LoginRequest):
    return loginUser(req.uid, req.pwd)


@app.get("/auth/verify")
def verify_token(request: Request):
    user = get_current_user(request)

    return {
        "uid": user["uid"],
        "role": user["role"],
        "name": user["name"]
    }


@app.post("/upload")
async def upload(request: Request, file: UploadFile = File(...)):
    user = get_current_user(request)

    file_id, ext = save_file(
        file,
        uploaded_by=user["uid"]
    )

    return {
        "status": "saved",
        "document_id": file_id,
        "ext": ext
    }