# services/auth_service.py

import bcrypt
import jwt
from datetime import datetime, timedelta, timezone

from config import SIGNATURE_KEY
from services.supabase_client import client

def registerUser(name, uid, pwd, role):
    hashed_pwd = bcrypt.hashpw(pwd.encode("utf-8"), bcrypt.gensalt()).decode()

    existing = client.table("users_v2") \
        .select("id") \
        .eq("username", uid) \
        .execute()

    if existing.data:
        return False

    client.table("users_v2").insert({
        "username": uid,
        "password_hash": hashed_pwd,
        "role": role,
        "name": name   # NEW
    }).execute()

    return True

def loginUser(uid, password):
    res = client.table("users_v2") \
        .select("id, password_hash, name, role") \
        .eq("username", uid) \
        .single() \
        .execute()

    if not res.data:
        return {"success": False, "token": None, "message": "User not found"}

    stored_pass = res.data["password_hash"].encode("utf-8")

    if not bcrypt.checkpw(password.encode("utf-8"), stored_pass):
        return {"success": False, "token": None, "message": "Wrong Password"}

    user_id = res.data["id"]

    current_time = datetime.now(timezone.utc)
    payload = {
        "uid": user_id,
        "iat": int(current_time.timestamp()),
        "exp": int((current_time + timedelta(hours=24)).timestamp())
    }

    token = jwt.encode(payload, SIGNATURE_KEY, algorithm="HS256")

    return {
        "success": True,
        "token": token,
        "message": "Login Successful",
        "name": res.data["name"],   # OPTIONAL for UI
        "role": res.data["role"]    # OPTIONAL for UI
    }

def verifyUser(token):
    try:
        payload = jwt.decode(token, SIGNATURE_KEY, algorithms=["HS256"])
        user_id = payload["uid"]

        res = client.table("users_v2") \
            .select("role, name") \
            .eq("id", user_id) \
            .single() \
            .execute()

        if not res.data:
            return {"valid": False}

        return {
            "valid": True,
            "uid": user_id,
            "role": res.data["role"],
            "name": res.data["name"]  # NEW
        }

    except Exception:
        return {"valid": False}