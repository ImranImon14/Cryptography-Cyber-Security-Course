<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SteganoVault — Result</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;700;800&family=DM+Mono:ital@0;1&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #0a0a0f;
            --surface: #111118;
            --border: #1e1e2e;
            --accent: #7fff6e;
            --accent2: #6e8fff;
            --text: #e8e8f0;
            --muted: #555570;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: var(--bg);
            color: var(--text);
            font-family: 'DM Mono', monospace;
            min-height: 100vh;
        }
        body::before {
            content: '';
            position: fixed;
            inset: 0;
            background-image:
                    linear-gradient(rgba(127,255,110,0.03) 1px, transparent 1px),
                    linear-gradient(90deg, rgba(127,255,110,0.03) 1px, transparent 1px);
            background-size: 40px 40px;
            pointer-events: none;
            z-index: 0;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 24px;
            position: relative;
            z-index: 1;
        }
        header { text-align: center; margin-bottom: 48px; }
        .logo {
            font-family: 'Syne', sans-serif;
            font-size: 2.2rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 36px;
            animation: fadeUp 0.5s ease;
        }
        .success-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: rgba(127,255,110,0.1);
            border: 1px solid rgba(127,255,110,0.3);
            color: var(--accent);
            padding: 6px 16px;
            border-radius: 100px;
            font-size: 0.8rem;
            letter-spacing: 1px;
            margin-bottom: 20px;
        }
        .result-title {
            font-family: 'Syne', sans-serif;
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 24px;
        }
        .image-wrapper {
            text-align: center;
            margin-bottom: 24px;
        }
        .image-wrapper img {
            max-width: 100%;
            max-height: 350px;
            border-radius: 12px;
            border: 1px solid var(--border);
        }
        .btn-download {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: var(--accent);
            color: #0a0a0f;
            border: none;
            border-radius: 10px;
            font-family: 'Syne', sans-serif;
            font-size: 1rem;
            font-weight: 700;
            padding: 14px 28px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
            letter-spacing: 1px;
        }
        .btn-download:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(127,255,110,0.25);
        }
        .message-label {
            font-size: 0.75rem;
            color: var(--muted);
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 10px;
        }
        .message-box {
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 24px;
            font-size: 1rem;
            line-height: 1.7;
            color: var(--accent);
            word-break: break-word;
            white-space: pre-wrap;
            margin-bottom: 16px;
        }
        .btn-copy {
            background: none;
            border: 1px solid var(--border);
            color: var(--muted);
            border-radius: 8px;
            padding: 8px 16px;
            font-family: 'DM Mono', monospace;
            font-size: 0.8rem;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-copy:hover { border-color: var(--accent2); color: var(--accent2); }
        .divider { height: 1px; background: var(--border); margin: 24px 0; }
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: none;
            border: 1px solid var(--border);
            color: var(--muted);
            border-radius: 10px;
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem;
            font-weight: 700;
            padding: 12px 24px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
        }
        .btn-back:hover { border-color: var(--text); color: var(--text); }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
<div class="container">
    <header>
        <a href="index.jsp" style="text-decoration:none;">
            <div class="logo">SteganoVault</div>
        </a>
    </header>

    <div class="card">
        <div class="success-badge">✓ <%= request.getAttribute("success") %></div>

        <% if (request.getAttribute("encodedImage") != null) { %>
        <div class="result-title">Your encoded image is ready!</div>
        <p style="color:var(--muted); font-size:0.85rem; margin-bottom:24px;">
            Secret message hidden inside the pixels. Download and share it!
        </p>
        <div class="image-wrapper">
            <img src="data:image/png;base64,<%= request.getAttribute("encodedImage") %>"
                 alt="Encoded Image" id="encodedImg">
        </div>
        <a class="btn-download" id="downloadLink" download="stegano_encoded.png" href="#">
            ⬇ Download Encoded Image
        </a>

        <% } else if (request.getAttribute("decodedMessage") != null) { %>
        <div class="result-title">Hidden message found!</div>
        <div class="message-label">Extracted Message</div>
        <div class="message-box" id="msgBox"><%= request.getAttribute("decodedMessage") %></div>
        <button class="btn-copy" onclick="copyMessage()">📋 Copy Message</button>
        <% } %>

        <div class="divider"></div>
        <a href="index.jsp" class="btn-back">← Back to Home</a>
    </div>
</div>

<script>
    window.onload = function() {
        const img = document.getElementById('encodedImg');
        const link = document.getElementById('downloadLink');
        if (img && link) { link.href = img.src; }
    }
    function copyMessage() {
        const msg = document.getElementById('msgBox').innerText;
        navigator.clipboard.writeText(msg).then(() => {
            const btn = document.querySelector('.btn-copy');
            btn.textContent = '✓ Copied!';
            setTimeout(() => btn.textContent = '📋 Copy Message', 2000);
        });
    }
</script>
</body>
</html>