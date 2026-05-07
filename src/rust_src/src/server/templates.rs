// Bolt Framework
// A blazing-fast HTTP framework for Ring
// Copyright (c) 2026, Youssef Saeed

//! Template Engine (MiniJinja)

use ring_lang_rs::*;

use crate::HTTP_SERVER_TYPE;

use super::HttpServer;
use crate::modules::json::ring_list_to_json;

/// bolt_render_template(server, template, data) → render template string with MiniJinja
ring_func!(bolt_render_template, |p| {
    ring_check_paracount!(p, 3);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);
    ring_check_list!(p, 3);

    let _ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);
    let template_str = ring_get_string!(p, 2);
    let list = ring_api_getlist(p, 3);
    let data = ring_list_to_json(list);

    let mut env = minijinja::Environment::new();
    env.set_fuel(Some(100_000));
    env.set_auto_escape_callback(|_| minijinja::AutoEscape::Html);
    if let Err(e) = env.add_template("template", template_str) {
        ring_error!(p, &format!("Template error: {}", e));
        return;
    }

    let tmpl = match env.get_template("template") {
        Ok(t) => t,
        Err(e) => {
            ring_error!(p, &format!("Template error: {}", e));
            return;
        }
    };

    match tmpl.render(&data) {
        Ok(result) => ring_ret_string!(p, &result),
        Err(e) => {
            ring_error!(p, &format!("Render error: {}", e));
        }
    }
});

/// bolt_render_file(server, filepath, data) → render template file with MiniJinja
ring_func!(bolt_render_file, |p| {
    ring_check_paracount!(p, 3);
    ring_check_cpointer!(p, 1);
    ring_check_string!(p, 2);
    ring_check_list!(p, 3);

    let _ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);

    let filepath = ring_get_string!(p, 2);

    // Reject path traversal attempts
    let path_obj = std::path::Path::new(filepath);
    for component in path_obj.components() {
        if component == std::path::Component::ParentDir {
            ring_error!(p, "Template path traversal detected: '..' not allowed");
            return;
        }
    }

    let ptr = ring_api_getcpointer(p, 1, HTTP_SERVER_TYPE);

    let template_str = unsafe {
        let server = &*(ptr as *const HttpServer);
        let cache = server
            .template_cache
            .read()
            .unwrap_or_else(|e| e.into_inner());
        if let Some((cached_content, cached_mtime)) = cache.get(filepath) {
            if let Ok(meta) = std::fs::metadata(filepath) {
                if let Ok(mtime) = meta.modified() {
                    let mtime_ms = mtime
                        .duration_since(std::time::UNIX_EPOCH)
                        .unwrap_or_default()
                        .as_millis();
                    if *cached_mtime == mtime_ms {
                        cached_content.clone()
                    } else {
                        drop(cache);
                        match std::fs::read_to_string(filepath) {
                            Ok(content) => {
                                let mut cache = server
                                    .template_cache
                                    .write()
                                    .unwrap_or_else(|e| e.into_inner());
                                const MAX_TEMPLATE_CACHE: usize = 1000;
                                if cache.len() >= MAX_TEMPLATE_CACHE {
                                    if let Some(key) = cache.keys().next().cloned() {
                                        cache.remove(&key);
                                    }
                                }
                                cache.insert(filepath.to_string(), (content.clone(), mtime_ms));
                                content
                            }
                            Err(_) => {
                                ring_ret_string!(p, "");
                                return;
                            }
                        }
                    }
                } else {
                    cached_content.clone()
                }
            } else {
                cached_content.clone()
            }
        } else {
            drop(cache);
            match std::fs::read_to_string(filepath) {
                Ok(content) => {
                    let mtime_ms = std::fs::metadata(filepath)
                        .and_then(|m| m.modified())
                        .unwrap_or(std::time::UNIX_EPOCH)
                        .duration_since(std::time::UNIX_EPOCH)
                        .unwrap_or_default()
                        .as_millis();
                    let mut cache = server
                        .template_cache
                        .write()
                        .unwrap_or_else(|e| e.into_inner());
                    // Prevent unbounded growth: evict an arbitrary entry if at capacity
                    const MAX_TEMPLATE_CACHE: usize = 1000;
                    if cache.len() >= MAX_TEMPLATE_CACHE {
                        if let Some(key) = cache.keys().next().cloned() {
                            cache.remove(&key);
                        }
                    }
                    cache.insert(filepath.to_string(), (content.clone(), mtime_ms));
                    content
                }
                Err(_) => {
                    ring_ret_string!(p, "");
                    return;
                }
            }
        }
    };

    let list = ring_api_getlist(p, 3);
    let data = ring_list_to_json(list);

    let dir = std::path::Path::new(filepath)
        .parent()
        .map(|p| p.to_path_buf())
        .unwrap_or_default();
    let template_name = std::path::Path::new(filepath)
        .file_name()
        .and_then(|n| n.to_str())
        .unwrap_or("template");

    let mut env = minijinja::Environment::new();
    env.set_fuel(Some(100_000));
    env.set_auto_escape_callback(|name| {
        if name.ends_with(".html") || name.ends_with(".htm") || name.ends_with(".xml") {
            minijinja::AutoEscape::Html
        } else if name == "template"
            || name.ends_with(".tpl")
            || name.ends_with(".j2")
            || name.ends_with(".jinja")
            || name.ends_with(".tmpl")
        {
            minijinja::AutoEscape::Html
        } else {
            minijinja::AutoEscape::None
        }
    });
    let dir_clone = dir.clone();
    env.set_loader(move |name| {
        if name.contains("..") {
            return Ok(None);
        }
        let path = dir_clone.join(name);
        match std::fs::read_to_string(&path) {
            Ok(content) => Ok(Some(content)),
            Err(_) => Ok(None),
        }
    });

    if let Err(e) = env.add_template(template_name, &template_str) {
        ring_error!(p, &format!("Template error: {}", e));
        return;
    }

    let tmpl = match env.get_template(template_name) {
        Ok(t) => t,
        Err(e) => {
            ring_error!(p, &format!("Template error: {}", e));
            return;
        }
    };

    match tmpl.render(&data) {
        Ok(result) => ring_ret_string!(p, &result),
        Err(e) => {
            ring_error!(p, &format!("Render error: {}", e));
        }
    }
});
