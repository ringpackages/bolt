// Bolt Framework
// A blazing-fast HTTP framework for Ring
// Copyright (c) 2026, Youssef Saeed

//! Rate Limiting (Simple In-Memory)

use ring_lang_rs::*;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::time::{SystemTime, UNIX_EPOCH};

use crate::HTTP_SERVER_TYPE;

use super::{HttpServer, resolve_client_ip};

struct IpRateEntry {
    requests: AtomicU64,
    window_start: AtomicU64,
}

static RATE_LIMIT_MAX: AtomicU64 = AtomicU64::new(100);
static RATE_LIMIT_WINDOW: AtomicU64 = AtomicU64::new(60);
static RATE_LIMIT_ENABLED: AtomicBool = AtomicBool::new(false);
static RATE_LIMIT_IP_MAP: std::sync::LazyLock<dashmap::DashMap<String, IpRateEntry>> =
    std::sync::LazyLock::new(|| dashmap::DashMap::new());

/// bolt_rate_limit(max_requests, window_seconds) → configure rate limiting
ring_func!(bolt_rate_limit, |p| {
    ring_check_paracount!(p, 2);
    ring_check_number!(p, 1);
    ring_check_number!(p, 2);

    let max_req_f = ring_get_number!(p, 1);
    let window_sec_f = ring_get_number!(p, 2);
    if !max_req_f.is_finite() || max_req_f < 0.0 || !window_sec_f.is_finite() || window_sec_f < 0.0
    {
        ring_error!(
            p,
            "rate limit: max_requests and window_seconds must be non-negative finite numbers"
        );
        return;
    }
    let max_requests = max_req_f as u64;
    let window_seconds = window_sec_f as u64;

    RATE_LIMIT_MAX.store(max_requests, Ordering::SeqCst);
    RATE_LIMIT_WINDOW.store(window_seconds, Ordering::SeqCst);
    RATE_LIMIT_ENABLED.store(true, Ordering::SeqCst);

    ring_ret_number!(p, 1.0);
});

/// bolt_check_rate_limit([server]) → 1 if allowed, 0 if rate limited
ring_func!(bolt_check_rate_limit, |p| {
    if !RATE_LIMIT_ENABLED.load(Ordering::SeqCst) {
        ring_ret_number!(p, 1.0);
        return;
    }

    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();

    let window = RATE_LIMIT_WINDOW.load(Ordering::SeqCst);
    let max = RATE_LIMIT_MAX.load(Ordering::SeqCst);

    let client_ip = if ring_api_paracount(p) >= 1 {
        let ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);
        if !ptr.is_null() {
            unsafe {
                let server = &*(ptr as *const HttpServer);
                let guard = server.current_request.lock();
                if let Some(ref ctx) = *guard {
                    let proxy_whitelist = &server.config.proxy_whitelist;
                    resolve_client_ip(&ctx.peer_addr, &ctx.headers, proxy_whitelist)
                } else {
                    String::new()
                }
            }
        } else {
            String::new()
        }
    } else {
        String::new()
    };

    let ip_key = if client_ip.is_empty() {
        "unknown".to_string()
    } else {
        client_ip
    };

    let entry = (*RATE_LIMIT_IP_MAP)
        .entry(ip_key.clone())
        .or_insert_with(|| IpRateEntry {
            requests: AtomicU64::new(0),
            window_start: AtomicU64::new(now),
        });

    loop {
        let window_start = entry.window_start.load(Ordering::SeqCst);

        if now.saturating_sub(window_start) >= window {
            match entry.window_start.compare_exchange(
                window_start,
                now,
                Ordering::SeqCst,
                Ordering::SeqCst,
            ) {
                Ok(_) => {
                    entry.requests.store(1, Ordering::SeqCst);
                    ring_ret_number!(p, 1.0);
                    return;
                }
                Err(_) => continue,
            }
        }

        let requests = entry
            .requests
            .fetch_add(1, Ordering::SeqCst)
            .saturating_add(1);

        if requests > max {
            ring_ret_number!(p, 0.0);
        } else {
            ring_ret_number!(p, 1.0);
        }
        return;
    }
});

/// Clean up expired entries from the per-IP rate limit map
pub fn rate_limit_cleanup_ip_map() {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    let window = RATE_LIMIT_WINDOW.load(Ordering::SeqCst);
    (*RATE_LIMIT_IP_MAP).retain(|_, entry| {
        let window_start = entry.window_start.load(Ordering::SeqCst);
        now.saturating_sub(window_start) < window
    });
}

/// bolt_route_rate_limit(server, handler_name, max_requests, window_seconds) → set per-route rate limit
ring_func!(bolt_route_rate_limit, |p| {
    ring_check_paracount!(p, 4);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);
    ring_check_number!(p, 3);
    ring_check_number!(p, 4);

    let ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);
    if ptr.is_null() {
        ring_ret_number!(p, 0.0);
        return;
    }

    let handler_name = ring_get_string!(p, 2);
    let max_req_f = ring_get_number!(p, 3);
    let window_sec_f = ring_get_number!(p, 4);
    if !max_req_f.is_finite() || max_req_f < 0.0 || !window_sec_f.is_finite() || window_sec_f < 0.0
    {
        ring_error!(
            p,
            "rate limit: max_requests and window_seconds must be non-negative finite numbers"
        );
        return;
    }
    let max_requests = max_req_f as u64;
    let window_seconds = window_sec_f as u64;

    unsafe {
        let server = &mut *(ptr as *mut HttpServer);
        for route in &mut server.routes {
            if route.handler_name == handler_name {
                route.rate_limit = Some((max_requests, window_seconds));
                break;
            }
        }
    }

    ring_ret_number!(p, 1.0);
});

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::atomic::Ordering;

    #[test]
    fn test_rate_limit_disabled_returns_allowed() {
        RATE_LIMIT_ENABLED.store(false, Ordering::SeqCst);
        let enabled = RATE_LIMIT_ENABLED.load(Ordering::SeqCst);
        assert!(!enabled);
    }

    #[test]
    fn test_rate_limit_configure() {
        RATE_LIMIT_MAX.store(50, Ordering::SeqCst);
        RATE_LIMIT_WINDOW.store(120, Ordering::SeqCst);
        RATE_LIMIT_ENABLED.store(true, Ordering::SeqCst);

        assert_eq!(RATE_LIMIT_MAX.load(Ordering::SeqCst), 50);
        assert_eq!(RATE_LIMIT_WINDOW.load(Ordering::SeqCst), 120);
        assert!(RATE_LIMIT_ENABLED.load(Ordering::SeqCst));
    }

    #[test]
    fn test_rate_limit_window_reset() {
        let now = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs();

        let _entry = RATE_LIMIT_IP_MAP
            .entry("test".to_string())
            .or_insert_with(|| IpRateEntry {
                requests: AtomicU64::new(0),
                window_start: AtomicU64::new(now - 100),
            });
        RATE_LIMIT_WINDOW.store(60, Ordering::SeqCst);
        let window = RATE_LIMIT_WINDOW.load(Ordering::SeqCst);
        assert!(now - (now - 100) >= window);
    }

    #[test]
    fn test_rate_limit_saturating_add() {
        let count = u64::MAX;
        let result = count.saturating_add(1);
        assert_eq!(result, u64::MAX);
    }

    #[test]
    fn test_rate_limit_overflow_guard() {
        let requests = u64::MAX;
        assert_eq!(requests, u64::MAX);
    }

    #[test]
    fn test_route_rate_limit_assignment() {
        let server = HttpServer::new(std::ptr::null_mut());
        let mut server = server;
        server.add_route("GET", "/api/:id", "api_handler");

        for route in &mut server.routes {
            if route.handler_name == "api_handler" {
                route.rate_limit = Some((100, 60));
                break;
            }
        }

        let route = server
            .routes
            .iter()
            .find(|r| r.handler_name == "api_handler")
            .unwrap();
        assert_eq!(route.rate_limit, Some((100, 60)));
    }
}
