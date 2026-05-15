// Bolt Framework
// A blazing-fast HTTP framework for Ring
// Copyright (c) 2026, Youssef Saeed

// Bolt homepage template
$bolt_homepage_template = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ name }} v{{ version }}</title>
    <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 448 512'%3E%3Cpath fill='%23f59e0b' d='M349.4 44.6c5.9-13.7 1.5-29.7-10.6-38.5s-28.6-8-39.9 1.8l-256 224c-10 8.8-13.6 22.9-8.9 35.3S50.7 288 64 288H175.5L98.6 467.4c-5.9 13.7-1.5 29.7 10.6 38.5s28.6 8 39.9-1.8l256-224c10-8.8 13.6-22.9 8.9-35.3s-16.6-20.7-29.9-20.7H272.5L349.4 44.6z'/%3E%3C/svg%3E"/>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #e0e0e0;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 60px 20px;
        }
        .card {
            text-align: center;
            max-width: 600px;
            width: 100%;
        }
        .logo svg {
            width: 80px;
            height: 80px;
            fill: #f59e0b;
            margin-bottom: 16px;
        }
        h1 {
            font-size: 56px;
            font-weight: 700;
            background: linear-gradient(90deg, #f59e0b, #fbbf24);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 12px;
        }
        .version-badge {
            display: inline-block;
            background: rgba(245, 158, 11, 0.15);
            border: 1px solid rgba(245, 158, 11, 0.3);
            color: #fbbf24;
            padding: 6px 20px;
            border-radius: 20px;
            font-size: 15px;
            font-weight: 600;
            letter-spacing: 0.5px;
            margin-bottom: 20px;
        }
        .description {
            color: #94a3b8;
            font-size: 18px;
            line-height: 1.6;
            margin-bottom: 32px;
        }
        .link-btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            padding: 14px 32px;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .link-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.3);
        }
        .link-docs {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
        }
        .link-docs svg {
            width: 18px;
            height: 18px;
            fill: currentColor;
        }
        .footer {
            margin-top: 48px;
            color: #64748b;
            font-size: 14px;
        }
        .footer a {
            color: #94a3b8;
            text-decoration: none;
            transition: color 0.2s ease;
        }
        .footer a:hover {
            color: #f59e0b;
        }
        .footer svg {
            width: 14px;
            height: 14px;
            fill: currentColor;
            vertical-align: middle;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="logo"><svg viewBox="0 0 448 512" xmlns="http://www.w3.org/2000/svg"><path d="M349.4 44.6c5.9-13.7 1.5-29.7-10.6-38.5s-28.6-8-39.9 1.8l-256 224c-10 8.8-13.6 22.9-8.9 35.3S50.7 288 64 288H175.5L98.6 467.4c-5.9 13.7-1.5 29.7 10.6 38.5s28.6 8 39.9-1.8l256-224c10-8.8 13.6-22.9 8.9-35.3s-16.6-20.7-29.9-20.7H272.5L349.4 44.6z"/></svg></div>
        <h1>{{ name }}</h1>
        <div class="version-badge">v{{ version }}</div>
        <p class="description">{{ description }}</p>
{% if has_docs %}
        <a href="/docs" class="link-btn link-docs"><svg viewBox="0 0 448 512" xmlns="http://www.w3.org/2000/svg"><path d="M96 0C43 0 0 43 0 96L0 416c0 53 43 96 96 96l288 0 32 0c17.7 0 32-14.3 32-32s-14.3-32-32-32l0-64c17.7 0 32-14.3 32-32l0-320c0-17.7-14.3-32-32-32L384 0 96 0zm0 384l256 0 0 64L96 448c-17.7 0-32-14.3-32-32s14.3-32 32-32zm32-240c0-8.8 7.2-16 16-16l192 0c8.8 0 16 7.2 16 16s-7.2 16-16 16l-192 0c-8.8 0-16-7.2-16-16zm16 48l192 0c8.8 0 16 7.2 16 16s-7.2 16-16 16l-192 0c-8.8 0-16-7.2-16-16s7.2-16 16-16z"/></svg> API Documentation</a>
{% endif %}
    </div>
    <div class="footer">
        <p>Built with <a href="https://github.com/ysdragon/bolt"><svg viewBox="0 0 448 512" xmlns="http://www.w3.org/2000/svg"><path d="M349.4 44.6c5.9-13.7 1.5-29.7-10.6-38.5s-28.6-8-39.9 1.8l-256 224c-10 8.8-13.6 22.9-8.9 35.3S50.7 288 64 288H175.5L98.6 467.4c-5.9 13.7-1.5 29.7 10.6 38.5s28.6 8 39.9-1.8l256-224c10-8.8 13.6-22.9 8.9-35.3s-16.6-20.7-29.9-20.7H272.5L349.4 44.6z"/></svg> {{ name }}</a> by <a href="https://github.com/ysdragon"><svg viewBox="0 0 496 512" xmlns="http://www.w3.org/2000/svg"><path d="M165.9 397.4c0 2-2.3 3.6-5.2 3.6-3.3.3-5.6-1.3-5.6-3.6 0-2 2.3-3.6 5.2-3.6 3-.3 5.6 1.3 5.6 3.6zm-31.1-4.5c-.7 2 1.3 4.3 4.3 4.9 2.6 1 5.6 0 6.2-2s-1.3-4.3-4.3-5.2c-2.6-.7-5.5.3-6.2 2.3zm44.2-1.7c-2.9.7-4.9 2.6-4.6 4.9.3 2 2.9 3.3 5.9 2.6 2.9-.7 4.9-2.6 4.6-4.6-.3-1.9-3-3.2-5.9-2.9zM244.8 8C106.1 8 0 113.3 0 252c0 110.9 69.8 205.8 169.5 239.2 12.8 2.3 17.3-5.6 17.3-12.1 0-6.2-.3-40.4-.3-61.4 0 0-70 15-84.7-29.8 0 0-11.4-29.1-27.8-36.6 0 0-22.9-15.7 1.6-15.4 0 0 24.9 2 38.6 25.8 21.9 38.6 58.6 27.5 72.9 20.9 2.3-16 8.8-27.1 16-33.7-55.9-6.2-112.3-14.3-112.3-110.5 0-27.5 7.6-41.3 23.6-58.9-2.6-6.5-11.1-33.3 2.6-67.9 20.9-6.5 69 27 69 27 20-5.6 41.5-8.5 62.8-8.5s42.8 2.9 62.8 8.5c0 0 48.1-33.6 69-27 13.7 34.7 5.2 61.4 2.6 67.9 16 17.7 25.8 31.5 25.8 58.9 0 96.5-58.9 104.2-114.8 110.5 9.2 7.9 17 22.9 17 46.4 0 33.7-.3 75.4-.3 83.6 0 6.5 4.6 14.4 17.3 12.1C428.2 457.8 496 362.9 496 252 496 113.3 383.5 8 244.8 8z"/></svg> {{ developer }}</a></p>
    </div>
</body>
</html>`