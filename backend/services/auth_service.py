import supabase, bcrypt, jwt
from config import SUPABASE_KEY, SUPABASE_URL, SIGNATURE_KEY
from datetime import datetime, timedelta, timezone

client = supabase.create_client(SUPABASE_URL, SUPABASE_KEY)

def registerUser(user_id, password):
    res = client.table("users").select("*").eq("username", user_id).execute()
    
    if len(res.data) > 0:
        return False
    
    salt = bcrypt.gensalt()
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')
    client.table("users").insert({"username": user_id, "password_hash": hashed_password}).execute()
    return True

def loginUser(user_id, password):
    res = client.table("users").select("*").eq("username", user_id).execute()
    
    if not res.data:
        return {"success": False, "token": None, "message": "User not found"}
    
    stored_pass = res.data[0]["password_hash"].encode("utf-8")
    
    if not bcrypt.checkpw(password.encode('utf-8'), stored_pass):
        return {"success": False, "token": None, "message": "Wrong Password"}
    
    current_time = datetime.now(timezone.utc)
    payload = {
        "uid": res.data[0]["id"],
        "iat": int(current_time.timestamp()),
        "exp": int((current_time + timedelta(hours=24)).timestamp())
    }
    token = jwt.encode(payload, SIGNATURE_KEY, algorithm="HS256")
    return {"success": True, "token": token, "message": "Login Successful"}

def verifyUser(token):
    try:
        payload = jwt.decode(token, SIGNATURE_KEY, algorithms=["HS256"])
        uid = payload.get("uid")
        if uid is None:
            return {"valid": False, "uid": None}
        return {"valid": True, "uid": uid}
    except jwt.ExpiredSignatureError:
        return {"valid": False, "uid": None}
    except jwt.InvalidTokenError:
        return {"valid": False, "uid": None}