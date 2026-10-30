#!/usr/bin/env python3
import http.cookiejar
import json
import os
import time
import urllib.error
import urllib.request

jar = http.cookiejar.CookieJar()
client = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))
request = urllib.request.Request(
    "http://localhost:3000/login",
    data=json.dumps({"user": "admin", "password": "niteshift-local-dev"}).encode(),
    headers={"Content-Type": "application/json"},
)
for attempt in range(60):
    try:
        with client.open(request, timeout=5) as response:
            response.read()
        break
    except (urllib.error.URLError, TimeoutError):
        if attempt == 59:
            raise
        time.sleep(2)

cookies = [
    {
        "name": cookie.name,
        "value": cookie.value,
        "domain": "localhost",
        "path": cookie.path,
        "expires": cookie.expires if cookie.expires is not None else -1,
        "httpOnly": cookie.has_nonstandard_attr("HttpOnly"),
        "secure": cookie.secure,
        "sameSite": "Lax",
    }
    for cookie in jar
]
if not any(cookie["name"] == "grafana_session" for cookie in cookies):
    raise RuntimeError("Grafana login did not return a session cookie")
state_path = os.environ["NITESHIFT_AUTH_STATE_FILE"]
with open(os.open(state_path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600), "w") as state:
    json.dump({"cookies": cookies, "origins": []}, state)
