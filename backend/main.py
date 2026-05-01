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


# =========================
# Models
# =========================
class ChatMessage(BaseModel):
    message: str


class AuthRequest(BaseModel):
    uid: str
    pwd: str
    role: str | None = None  # optional → default handled in backend


# =========================
# Helper: extract user from token
# =========================
def get_current_user(request: Request):
    auth_header = request.headers.get("Authorization")

    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or malformed token")

    token = auth_header.split(" ")[1]
    result = verifyUser(token)

    if not result["valid"]:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    return result  # { uid, role, valid }


# =========================
# Chat (role-aware search)
# =========================
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


# =========================
# Register
# =========================
@app.post("/register")
def register(req: AuthRequest):
    role = req.role if req.role else "intern"  # enforce lowest privilege default

    success = registerUser(req.uid, req.pwd, role)

    if success:
        return {"response": True, "message": "User registered"}

    return {"response": False, "message": "Username already exists"}


# =========================
# Login
# =========================
@app.post("/login")
def login_endpoint(req: AuthRequest):
    return loginUser(req.uid, req.pwd)


# =========================
# Verify Token
# =========================
@app.get("/auth/verify")
def verify_token(request: Request):
    user = get_current_user(request)
    return {"uid": user["uid"], "role": user["role"]}


# =========================
# Upload (bind to user)
# =========================
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