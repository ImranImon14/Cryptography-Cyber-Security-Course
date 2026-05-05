<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SteganoVault — Hide Messages in Images</title>
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
            --danger: #ff6e6e;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: var(--bg);
            color: var(--text);
            font-family: 'DM Mono', monospace;
            min-height: 100vh;
            overflow-x: hidden;
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
            max-width: 1000px;
            margin: 0 auto;
            padding: 40px 24px;
            position: relative;
            z-index: 1;
        }
        header {
            text-align: center;
            margin-bottom: 60px;
            animation: fadeDown 0.6s ease;
        }
        .logo {
            font-family: 'Syne', sans-serif;
            font-size: 3rem;
            font-weight: 800;
            letter-spacing: -2px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .tagline {
            color: var(--muted);
            font-size: 0.85rem;
            margin-top: 8px;
            letter-spacing: 3px;
            text-transform: uppercase;
        }
        .alert {
            background: rgba(255,110,110,0.1);
            border: 1px solid var(--danger);
            color: var(--danger);
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 0.9rem;
        }
        .tabs {
            display: flex;
            margin-bottom: 32px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 4px;
            width: fit-content;
        }
        .tab-btn {
            background: none;
            border: none;
            color: var(--muted);
            font-family: 'Syne', sans-serif;
            font-size: 0.95rem;
            font-weight: 700;
            padding: 10px 28px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
            letter-spacing: 1px;
        }
        .tab-btn.active { background: var(--accent); color: #0a0a0f; }
        .tab-btn:not(.active):hover { color: var(--text); }
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 36px;
            display: none;
            animation: fadeUp 0.4s ease;
        }
        .card.active { display: block; }
        .card-title {
            font-family: 'Syne', sans-serif;
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .card-desc {
            color: var(--muted);
            font-size: 0.82rem;
            margin-bottom: 28px;
        }
        .form-group { margin-bottom: 20px; }
        label {
            display: block;
            font-size: 0.78rem;
            color: var(--muted);
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 8px;
        }

        /* Source selector buttons */
        .source-selector {
            display: flex;
            gap: 10px;
            margin-bottom: 16px;
        }
        .source-btn {
            flex: 1;
            background: var(--bg);
            border: 1px solid var(--border);
            color: var(--muted);
            font-family: 'Syne', sans-serif;
            font-size: 0.85rem;
            font-weight: 700;
            padding: 10px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.2s;
            letter-spacing: 1px;
        }
        .source-btn.active {
            border-color: var(--accent);
            color: var(--accent);
            background: rgba(127,255,110,0.05);
        }
        .source-btn:hover { border-color: var(--muted); color: var(--text); }

        /* Upload zone */
        .upload-zone {
            border: 2px dashed var(--border);
            border-radius: 12px;
            padding: 40px;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
        }
        .upload-zone:hover, .upload-zone.dragover {
            border-color: var(--accent);
            background: rgba(127,255,110,0.04);
        }
        .upload-zone input[type="file"] {
            position: absolute;
            inset: 0;
            opacity: 0;
            cursor: pointer;
            width: 100%;
            height: 100%;
        }
        .upload-icon { font-size: 2rem; margin-bottom: 10px; }
        .upload-text { color: var(--muted); font-size: 0.85rem; }
        .upload-text span { color: var(--accent); }
        .preview-img {
            max-width: 100%;
            max-height: 200px;
            border-radius: 8px;
            margin-top: 12px;
            display: none;
        }

        /* Camera section */
        .camera-section {
            display: none;
            border: 1px solid var(--border);
            border-radius: 12px;
            overflow: hidden;
        }
        .camera-section.active { display: block; }

        .camera-feed {
            position: relative;
            background: #000;
            text-align: center;
        }
        #videoElement {
            width: 100%;
            max-height: 300px;
            object-fit: cover;
            display: block;
        }
        canvas { display: none; }

        .camera-controls {
            display: flex;
            gap: 10px;
            padding: 14px;
            background: var(--bg);
            justify-content: center;
            flex-wrap: wrap;
        }
        .cam-btn {
            background: none;
            border: 1px solid var(--border);
            color: var(--muted);
            font-family: 'DM Mono', monospace;
            font-size: 0.82rem;
            padding: 8px 18px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .cam-btn:hover { border-color: var(--text); color: var(--text); }
        .cam-btn.capture {
            background: var(--accent);
            border-color: var(--accent);
            color: #0a0a0f;
            font-weight: 700;
        }
        .cam-btn.capture:hover {
            box-shadow: 0 4px 16px rgba(127,255,110,0.3);
        }
        .cam-btn.retake {
            border-color: var(--danger);
            color: var(--danger);
        }

        /* Captured image preview */
        .captured-preview {
            display: none;
            text-align: center;
            padding: 16px;
            background: var(--bg);
        }
        .captured-preview img {
            max-width: 100%;
            max-height: 250px;
            border-radius: 10px;
            border: 1px solid var(--border);
        }
        .captured-label {
            font-size: 0.75rem;
            color: var(--accent);
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 10px;
        }

        /* Camera start prompt */
        .cam-start-prompt {
            padding: 40px;
            text-align: center;
            background: var(--bg);
        }
        .cam-start-prompt p {
            color: var(--muted);
            font-size: 0.85rem;
            margin-bottom: 16px;
        }
        .btn-start-cam {
            background: var(--accent2);
            border: none;
            color: #fff;
            font-family: 'Syne', sans-serif;
            font-size: 0.9rem;
            font-weight: 700;
            padding: 12px 24px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.2s;
            letter-spacing: 1px;
        }
        .btn-start-cam:hover {
            box-shadow: 0 6px 20px rgba(110,143,255,0.3);
            transform: translateY(-1px);
        }

        textarea {
            width: 100%;
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 10px;
            color: var(--text);
            font-family: 'DM Mono', monospace;
            font-size: 0.9rem;
            padding: 14px 16px;
            resize: vertical;
            min-height: 120px;
            transition: border-color 0.2s;
            outline: none;
        }
        textarea:focus { border-color: var(--accent); }
        textarea::placeholder { color: var(--muted); }

        .btn {
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
            padding: 14px 32px;
            cursor: pointer;
            transition: all 0.2s;
            letter-spacing: 1px;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(127,255,110,0.25);
        }
        .btn.decode { background: var(--accent2); }
        .btn.decode:hover { box-shadow: 0 8px 24px rgba(110,143,255,0.25); }
        .btn:disabled {
            opacity: 0.4;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .info-box {
            background: rgba(127,255,110,0.05);
            border: 1px solid rgba(127,255,110,0.15);
            border-radius: 10px;
            padding: 14px 18px;
            margin-bottom: 24px;
            font-size: 0.8rem;
            color: var(--muted);
            line-height: 1.6;
        }
        .info-box strong { color: var(--accent); }

        /* Hidden file input for camera captured image */
        #cameraFileInput { display: none; }

        @keyframes fadeDown {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to { opacity: 1; transform: translateY(0); }
        }
        footer {
            text-align: center;
            margin-top: 60px;
            color: var(--muted);
            font-size: 0.75rem;
            letter-spacing: 1px;
        }
    </style>
</head>
<body>
<div class="container">

    <header>
        <div class="logo">SteganoVault</div>
        <div class="tagline">Hide secrets inside images · LSB Steganography</div>
    </header>

    <% if (request.getAttribute("error") != null) { %>
    <div class="alert">⚠ <%= request.getAttribute("error") %></div>
    <% } %>

    <div class="tabs">
        <button class="tab-btn active" onclick="switchTab('encode', this)">🔒 Encode</button>
        <button class="tab-btn" onclick="switchTab('decode', this)">🔓 Decode</button>
    </div>

    <!-- ENCODE CARD -->
    <div class="card active" id="encode-card">
        <div class="card-title">Hide a Message</div>
        <div class="card-desc">Upload or capture an image, then type your secret message.</div>

        <div class="info-box">
            <strong>Tip:</strong> Use PNG or BMP images only. JPEG compression destroys hidden data.
        </div>

        <form action="encode" method="post" enctype="multipart/form-data" id="encodeForm">

            <!-- Hidden input — camera captured image এখানে যাবে -->
            <input type="file" name="image" id="cameraFileInput" accept="image/png">

            <div class="form-group">
                <label>Image Source</label>
                <div class="source-selector">
                    <button type="button" class="source-btn active" onclick="selectSource('browse')">
                        📁 Browse File
                    </button>
                    <button type="button" class="source-btn" onclick="selectSource('camera')">
                        📷 Use Camera
                    </button>
                </div>

                <!-- BROWSE MODE -->
                <div id="browse-section">
                    <div class="upload-zone">
                        <input type="file" name="image" id="browseInput" accept=".png,.bmp"
                               onchange="previewImage(this, 'browse-preview')">
                        <div class="upload-icon">🖼</div>
                        <div class="upload-text">Drop image here or <span>click to browse</span></div>
                        <img id="browse-preview" class="preview-img" alt="preview">
                    </div>
                </div>

                <!-- CAMERA MODE -->
                <div class="camera-section" id="camera-section">

                    <!-- Start prompt -->
                    <div class="cam-start-prompt" id="cam-start-prompt">
                        <p>Click below to turn on your camera</p>
                        <button type="button" class="btn-start-cam" onclick="startCamera()">
                            📷 Start Camera
                        </button>
                    </div>

                    <!-- Live feed -->
                    <div class="camera-feed" id="camera-feed" style="display:none;">
                        <video id="videoElement" autoplay playsinline></video>
                        <canvas id="captureCanvas"></canvas>
                    </div>

                    <!-- Camera controls -->
                    <div class="camera-controls" id="camera-controls" style="display:none;">
                        <button type="button" class="cam-btn" onclick="switchCameraFacing()">🔄 Flip Camera</button>
                        <button type="button" class="cam-btn capture" onclick="capturePhoto()">📸 Capture</button>
                        <button type="button" class="cam-btn" onclick="stopCamera()">✕ Stop</button>
                    </div>

                    <!-- Captured preview -->
                    <div class="captured-preview" id="captured-preview">
                        <div class="captured-label">✓ Photo Captured</div>
                        <img id="capturedImg" alt="Captured">
                        <div class="camera-controls">
                            <button type="button" class="cam-btn retake" onclick="retakePhoto()">🔄 Retake</button>
                        </div>
                    </div>

                </div>
            </div>

            <div class="form-group">
                <label>Secret Message</label>
                <textarea name="message" placeholder="Type your secret message here..." required></textarea>
            </div>

            <button type="submit" class="btn" id="encodeSubmitBtn">🔒 Encode & Download</button>
        </form>
    </div>

    <!-- DECODE CARD -->
    <div class="card" id="decode-card">
        <div class="card-title">Extract a Message</div>
        <div class="card-desc">Upload an image encoded with SteganoVault to reveal the hidden message.</div>

        <form action="decode" method="post" enctype="multipart/form-data">
            <div class="form-group">
                <label>Encoded Image (PNG)</label>
                <div class="upload-zone">
                    <input type="file" name="image" accept=".png,.bmp" required
                           onchange="previewImage(this, 'decode-preview')">
                    <div class="upload-icon">🔍</div>
                    <div class="upload-text">Drop encoded image here or <span>click to browse</span></div>
                    <img id="decode-preview" class="preview-img" alt="preview">
                </div>
            </div>
            <button type="submit" class="btn decode">🔓 Decode Message</button>
        </form>
    </div>

    <footer>SteganoVault · LSB Bit Manipulation · Java + JSP</footer>
</div>

<script>
    // ===================== TAB =====================
    function switchTab(tab, btn) {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.card').forEach(c => c.classList.remove('active'));
        btn.classList.add('active');
        document.getElementById(tab + '-card').classList.add('active');
    }

    // ===================== BROWSE PREVIEW =====================
    function previewImage(input, previewId) {
        const preview = document.getElementById(previewId);
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = e => {
                preview.src = e.target.result;
                preview.style.display = 'block';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Drag and drop
    document.querySelectorAll('.upload-zone').forEach(zone => {
        zone.addEventListener('dragover', e => { e.preventDefault(); zone.classList.add('dragover'); });
        zone.addEventListener('dragleave', () => zone.classList.remove('dragover'));
        zone.addEventListener('drop', () => zone.classList.remove('dragover'));
    });

    // ===================== SOURCE SELECTOR =====================
    let currentMode = 'browse';

    function selectSource(mode) {
        currentMode = mode;
        document.querySelectorAll('.source-btn').forEach(b => b.classList.remove('active'));
        event.target.classList.add('active');

        const browseSection = document.getElementById('browse-section');
        const cameraSection = document.getElementById('camera-section');
        const browseInput   = document.getElementById('browseInput');

        if (mode === 'browse') {
            browseSection.style.display = 'block';
            cameraSection.classList.remove('active');
            browseInput.required = true;
            stopCamera();
        } else {
            browseSection.style.display = 'none';
            cameraSection.classList.add('active');
            browseInput.required = false;
        }
    }

    // ===================== CAMERA =====================
    let stream = null;
    let facingMode = 'environment'; // back camera default
    let capturedBlob = null;

    async function startCamera() {
        try {
            stream = await navigator.mediaDevices.getUserMedia({
                video: { facingMode: facingMode, width: { ideal: 1280 }, height: { ideal: 720 } }
            });

            const video = document.getElementById('videoElement');
            video.srcObject = stream;

            document.getElementById('cam-start-prompt').style.display = 'none';
            document.getElementById('camera-feed').style.display = 'block';
            document.getElementById('camera-controls').style.display = 'flex';
            document.getElementById('captured-preview').style.display = 'none';
            capturedBlob = null;

        } catch (err) {
            alert('Camera access denied or not available!\nError: ' + err.message);
        }
    }

    async function switchCameraFacing() {
        facingMode = facingMode === 'environment' ? 'user' : 'environment';
        stopStream();
        await startCamera();
    }

    function capturePhoto() {
        const video  = document.getElementById('videoElement');
        const canvas = document.getElementById('captureCanvas');

        canvas.width  = video.videoWidth;
        canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);

        // canvas → blob → File
        canvas.toBlob(blob => {
            capturedBlob = blob;

            // Preview দেখাও
            const capturedImg = document.getElementById('capturedImg');
            capturedImg.src = canvas.toDataURL('image/png');

            // Camera feed লুকাও, preview দেখাও
            document.getElementById('camera-feed').style.display = 'none';
            document.getElementById('camera-controls').style.display = 'none';
            document.getElementById('captured-preview').style.display = 'block';

            stopStream();
        }, 'image/png');
    }

    function retakePhoto() {
        capturedBlob = null;
        document.getElementById('captured-preview').style.display = 'none';
        document.getElementById('cam-start-prompt').style.display = 'block';
    }

    function stopCamera() {
        stopStream();
        document.getElementById('cam-start-prompt').style.display = 'block';
        document.getElementById('camera-feed').style.display = 'none';
        document.getElementById('camera-controls').style.display = 'none';
        document.getElementById('captured-preview').style.display = 'none';
        capturedBlob = null;
    }

    function stopStream() {
        if (stream) {
            stream.getTracks().forEach(t => t.stop());
            stream = null;
        }
    }

    // ===================== FORM SUBMIT =====================
    document.getElementById('encodeForm').addEventListener('submit', function(e) {
        if (currentMode === 'camera') {
            if (!capturedBlob) {
                e.preventDefault();
                alert('Please capture a photo first!');
                return;
            }

            e.preventDefault();

            // Captured blob কে FormData দিয়ে submit করো
            const formData = new FormData(this);
            formData.delete('image'); // পুরনো empty field সরাও
            formData.append('image', capturedBlob, 'camera_capture.png');

            fetch('encode', {
                method: 'POST',
                body: formData
            }).then(response => response.text())
                .then(html => {
                    document.open();
                    document.write(html);
                    document.close();
                }).catch(err => alert('Upload failed: ' + err.message));
        }
        // browse mode এ normal form submit হবে
    });
</script>
</body>
</html>