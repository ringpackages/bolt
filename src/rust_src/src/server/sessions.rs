// Bolt Framework
// A blazing-fast HTTP framework for Ring
// Copyright (c) 2026, Youssef Saeed

//! Session Functions

use ring_lang_rs::*;
use std::collections::HashMap;
use std::sync::Arc;

use crate::HTTP_SERVER_TYPE;

use super::{HttpServer, PendingResponse, ResponseBody};

use base64::Engine;
use hmac::{Hmac, Mac};
use sha2::Sha256;

type HmacSha256 = Hmac<Sha256>;

/// Sign a session ID with the server secret to prevent fixation attacks.
/// Format: "{uuid}.{base64_hmac}"
pub fn sign_session_id(session_id: &str, secret: &str) -> String {
    let mut mac = match HmacSha256::new_from_slice(secret.as_bytes()) {
        Ok(m) => m,
        Err(_) => return session_id.to_string(),
    };
    mac.update(session_id.as_bytes());
    let sig = mac.finalize().into_bytes();
    let b64 = base64::engine::general_purpose::URL_SAFE_NO_PAD.encode(sig);
    format!("{}.{}", session_id, b64)
}

/// Verify a signed session ID. Returns the raw UUID if valid, None otherwise.
pub fn verify_session_id(signed: &str, secret: &str) -> Option<String> {
    let dot_pos = signed.rfind('.')?;
    let (raw_id, sig_b64) = signed.split_at(dot_pos);
    let sig_b64 = &sig_b64[1..]; // skip the '.'
    if raw_id.is_empty() || sig_b64.is_empty() {
        return None;
    }
    let sig = base64::engine::general_purpose::URL_SAFE_NO_PAD
        .decode(sig_b64)
        .ok()?;

    let mut mac = HmacSha256::new_from_slice(secret.as_bytes()).ok()?;
    mac.update(raw_id.as_bytes());
    mac.verify_slice(&sig).ok()?;
    Some(raw_id.to_string())
}

/// Generate a new random session ID (raw UUID, not signed).
pub fn generate_session_id() -> String {
    uuid::Uuid::new_v4().to_string()
}

/// bolt_session_set(server, key, value) - set session value
ring_func!(bolt_session_set, |p| {
    ring_check_paracount!(p, 3);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);
    ring_check_string!(p, 3);

    let ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);
    if ptr.is_null() {
        ring_error!(p, "Invalid HTTP server");
        return;
    }

    let key = ring_get_string!(p, 2);
    let value = ring_get_string!(p, 3);

    unsafe {
        let server = &*(ptr as *const HttpServer);

        let session_id = {
            let guard = server.current_request.lock();
            guard
                .as_ref()
                .map(|ctx| ctx.session_id.clone())
                .unwrap_or_default()
        };

        if !session_id.is_empty() {
            let session = server
                .sessions
                .get(&session_id)
                .unwrap_or_else(|| Arc::new(std::sync::Mutex::new(HashMap::new())));
            session
                .lock()
                .unwrap()
                .insert(key.to_string(), value.to_string());
            server.sessions.insert(session_id.clone(), session);

            let mut response = server.current_response.lock();
            let (cookie_name, secure_flag) =
                if server.tls.enabled || server.config.force_secure_cookies {
                    ("__Host-BOLTSESSION", "; Secure")
                } else {
                    ("BOLTSESSION", "")
                };
            // Sign session ID before placing in cookie to prevent fixation
            let signed_id = sign_session_id(&session_id, &server.session_secret);
            let cookie = cookie::Cookie::parse(format!(
                "{}={}; Path=/; HttpOnly; SameSite=Lax{}",
                cookie_name, signed_id, secure_flag
            ))
            .map(|c| c.to_string())
            .unwrap_or_else(|_| {
                format!(
                    "{}={}; Path=/; HttpOnly; SameSite=Lax{}",
                    cookie_name, signed_id, secure_flag
                )
            });
            if let Some(ref mut res) = *response {
                if !res
                    .cookies
                    .iter()
                    .any(|c| c.starts_with("BOLTSESSION=") || c.starts_with("__Host-BOLTSESSION="))
                {
                    res.cookies.push(cookie);
                }
            } else {
                *response = Some(PendingResponse {
                    status: 200,
                    headers: HashMap::new(),
                    cookies: vec![cookie],
                    body: ResponseBody::Bytes(Vec::new()),
                    only_headers: true,
                });
            }
        }
    }

    ring_ret_number!(p, 1.0);
});

/// bolt_session_get(server, key) -> value
ring_func!(bolt_session_get, |p| {
    ring_check_paracount!(p, 2);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);

    let ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);
    if ptr.is_null() {
        return;
    }

    let key = ring_get_string!(p, 2);

    unsafe {
        let server = &*(ptr as *const HttpServer);

        let session_id = {
            let guard = server.current_request.lock();
            guard
                .as_ref()
                .map(|ctx| ctx.session_id.clone())
                .unwrap_or_default()
        };

        if !session_id.is_empty() {
            if let Some(session) = server.sessions.get(&session_id) {
                let guard = session.lock().unwrap();
                if let Some(value) = guard.get(key) {
                    ring_ret_string!(p, value.as_str());
                    return;
                }
            }
        }
        ring_ret_string!(p, "");
    }
});

/// bolt_session_delete(server, key) - delete session key
ring_func!(bolt_session_delete, |p| {
    ring_check_paracount!(p, 2);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);

    let ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);
    if ptr.is_null() {
        ring_error!(p, "Invalid HTTP server");
        return;
    }

    let key = ring_get_string!(p, 2);

    unsafe {
        let server = &*(ptr as *const HttpServer);

        let session_id = {
            let guard = server.current_request.lock();
            guard
                .as_ref()
                .map(|ctx| ctx.session_id.clone())
                .unwrap_or_default()
        };

        if !session_id.is_empty() {
            if let Some(session) = server.sessions.get(&session_id) {
                session.lock().unwrap().remove(key);
                server.sessions.insert(session_id, session);
            }
        }
    }

    ring_ret_number!(p, 1.0);
});

/// bolt_session_regenerate(server) - regenerate session ID (prevents fixation)
ring_func!(bolt_session_regenerate, |p| {
    ring_check_paracount!(p, 1);
    ring_check_cpointer!(p, 1);

    let ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);
    if ptr.is_null() {
        ring_error!(p, "Invalid HTTP server");
        return;
    }

    unsafe {
        let server = &*(ptr as *const HttpServer);

        let old_session_id = {
            let guard = server.current_request.lock();
            guard
                .as_ref()
                .map(|ctx| ctx.session_id.clone())
                .unwrap_or_default()
        };

        if !old_session_id.is_empty() {
            let new_session_id = uuid::Uuid::new_v4().to_string();
            if let Some(session_data) = server.sessions.get(&old_session_id) {
                server
                    .sessions
                    .insert(new_session_id.clone(), session_data.clone());
            }
            server.sessions.invalidate(&old_session_id);

            // Update the request context's session_id
            if let Some(ref mut ctx) = *server.current_request.lock() {
                ctx.session_id = new_session_id.clone();
            }

            let (cookie_name, secure_flag) =
                if server.tls.enabled || server.config.force_secure_cookies {
                    ("__Host-BOLTSESSION", "; Secure")
                } else {
                    ("BOLTSESSION", "")
                };
            // Sign the new session ID before placing in cookie
            let signed_new = sign_session_id(&new_session_id, &server.session_secret);
            let cookie = cookie::Cookie::parse(format!(
                "{}={}; Path=/; HttpOnly; SameSite=Lax{}",
                cookie_name, signed_new, secure_flag
            ))
            .map(|c| c.to_string())
            .unwrap_or_else(|_| {
                format!(
                    "{}={}; Path=/; HttpOnly; SameSite=Lax{}",
                    cookie_name, signed_new, secure_flag
                )
            });

            let mut response = server.current_response.lock();
            if let Some(ref mut res) = *response {
                res.cookies.retain(|c| {
                    !c.starts_with("BOLTSESSION=") && !c.starts_with("__Host-BOLTSESSION=")
                });
                res.cookies.push(cookie);
            } else {
                *response = Some(PendingResponse {
                    status: 200,
                    headers: HashMap::new(),
                    cookies: vec![cookie],
                    body: ResponseBody::Bytes(Vec::new()),
                    only_headers: true,
                });
            }
        }
    }

    ring_ret_number!(p, 1.0);
});

/// bolt_session_clear(server) - clear all session data
ring_func!(bolt_session_clear, |p| {
    ring_check_paracount!(p, 1);
    ring_check_cpointer!(p, 1);

    let ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);
    if ptr.is_null() {
        ring_error!(p, "Invalid HTTP server");
        return;
    }

    unsafe {
        let server = &*(ptr as *const HttpServer);

        let session_id = {
            let guard = server.current_request.lock();
            guard
                .as_ref()
                .map(|ctx| ctx.session_id.clone())
                .unwrap_or_default()
        };

        if !session_id.is_empty() {
            server.sessions.invalidate(&session_id);

            let mut response = server.current_response.lock();
            let (_cookie_name, expired_cookie) =
                if server.tls.enabled || server.config.force_secure_cookies {
                    (
                        "__Host-BOLTSESSION",
                        "__Host-BOLTSESSION=; Path=/; HttpOnly; SameSite=Lax; Secure; Max-Age=0",
                    )
                } else {
                    (
                        "BOLTSESSION",
                        "BOLTSESSION=; Path=/; HttpOnly; SameSite=Lax; Max-Age=0",
                    )
                };
            if let Some(ref mut res) = *response {
                res.cookies.retain(|c| {
                    !c.starts_with("BOLTSESSION=") && !c.starts_with("__Host-BOLTSESSION=")
                });
                res.cookies.push(expired_cookie.to_string());
            } else {
                *response = Some(PendingResponse {
                    status: 200,
                    headers: HashMap::new(),
                    cookies: vec![expired_cookie.to_string()],
                    body: ResponseBody::Bytes(Vec::new()),
                    only_headers: true,
                });
            }
        }
    }

    ring_ret_number!(p, 1.0);
});
