<%-- 
    Document   : admin
    Created on : Dec 20, 2025
    Updated    : Jan 05, 2026 (Real Chat DB & Notes)
    Author     : andik
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="com.makancuy.model.User" %>

<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard Pro - MakanCuy</title>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.29/jspdf.plugin.autotable.min.js"></script>
    <script src="https://cdn.sheetjs.com/xlsx-0.20.0/package/dist/xlsx.full.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    
    <style>
        :root { --bg: #0d0d0d; --sidebar: #111; --card: #1a1a1a; --accent: #ccff00; --text: #fff; --hover: #222; }
        * { box-sizing: border-box; }
        
        body { background: var(--bg); color: var(--text); font-family: 'Space Grotesk', sans-serif; margin: 0; display: flex; height: 100vh; overflow: hidden; }

        /* SIDEBAR */
        .sidebar { width: 260px; background: var(--sidebar); border-right: 1px solid #333; display: flex; flex-direction: column; padding: 20px; flex-shrink: 0; transition: 0.3s; z-index: 1000; }
        .brand { font-size: 1.5rem; font-weight: bold; color: var(--accent); margin-bottom: 40px; letter-spacing: 2px; }
        .nav-link { display: flex; align-items: center; padding: 15px; color: #888; text-decoration: none; margin-bottom: 5px; border-radius: 10px; transition: 0.3s; cursor: pointer; position: relative; }
        .nav-link:hover, .nav-link.active { background: var(--accent); color: #000; font-weight: bold; }
        .nav-icon { margin-right: 15px; font-size: 1.2rem; }
        .badge { background: #ff4757; color: white; padding: 2px 6px; border-radius: 50%; font-size: 0.7rem; position: absolute; right: 15px; display: none; } /* Hidden default */
        
        .main-content { flex: 1; padding: 30px; overflow-y: auto; position: relative; }
        
        /* HAMBURGER */
        .hamburger { display: none; font-size: 1.5rem; background: none; border: none; color: #fff; cursor: pointer; margin-bottom: 20px; }
        .overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 900; }

        /* TABS */
        .tab-section { display: none; animation: fadeIn 0.4s; }
        .tab-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        
        /* CARDS & TABLES */
        .card { background: var(--card); padding: 25px; border: 1px solid #333; border-radius: 15px; margin-bottom: 20px; }
        .card-highlight { border-color: var(--accent); }
        .table-responsive { width: 100%; overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; min-width: 600px; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #333; vertical-align: middle; }
        th { color: var(--accent); text-transform: uppercase; font-size: 0.8rem; white-space: nowrap; }
        
        /* INPUTS */
        .btn { padding: 10px 20px; border-radius: 8px; border: none; font-weight: bold; cursor: pointer; text-decoration: none; font-size: 0.9rem; }
        .btn-primary { background: var(--accent); color: #000; width: 100%; margin-top: 10px; }
        .custom-select { width: auto; min-width: 120px; background: #000; color: #fff; border: 1px solid var(--accent); padding: 8px 12px; border-radius: 8px; font-weight: bold; cursor: pointer; display: inline-block; margin-bottom: 0; }
        input, select, textarea { width: 100%; padding: 12px; background: #000; border: 1px solid #333; color: #fff; margin-bottom: 15px; border-radius: 8px; font-family: inherit; }
        
        .chart-container { position: relative; height: 350px; width: 100%; overflow: hidden; }
        .user-info { margin-top: auto; padding-top: 20px; border-top: 1px solid #333; font-size: 0.9rem; color: #555; }
        
        /* ORDER CARD */
        .order-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .order-card { background: #222; border: 1px solid #444; border-radius: 12px; padding: 20px; display: flex; flex-direction: column; position: relative; }
        .order-card.priority { border-color: var(--accent); box-shadow: 0 0 10px rgba(204, 255, 0, 0.1); }
        .order-header { display: flex; justify-content: space-between; border-bottom: 1px dashed #555; padding-bottom: 10px; margin-bottom: 10px; }
        .order-items { background: #111; padding: 10px; border-radius: 8px; margin-bottom: 10px; font-size: 0.9rem; color: #ddd; line-height: 1.6; min-height: 60px; }
        .order-note { background: rgba(255, 71, 87, 0.1); border-left: 3px solid #ff4757; padding: 8px; font-size: 0.85rem; color: #ffb8b8; margin-bottom: 10px; border-radius: 4px; font-style: italic; }
        .item-row { border-bottom: 1px solid #333; padding: 4px 0; display:flex; justify-content:space-between; }
        
        .action-container { margin-top: auto; display: flex; gap: 10px; }
        .status-select { width: 100%; padding: 10px; background: #333; color: #fff; border: 1px solid #555; border-radius: 8px; cursor: pointer; font-weight: bold; }
        .status-select:focus { border-color: var(--accent); outline: none; }

        .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 0.8rem; border: 1px solid; display: inline-block; white-space: nowrap; }
        .status-paid { color: #facc15; border-color: #facc15; background: rgba(250, 204, 21, 0.1); }
        .status-process { color: #4ade80; border-color: #4ade80; background: rgba(74, 222, 128, 0.1); }
        .status-reject { color: #f87171; border-color: #f87171; background: rgba(248, 113, 113, 0.1); }

        /* CHAT ADMIN LAYOUT */
        .chat-layout { display: grid; grid-template-columns: 250px 1fr; height: 500px; gap: 20px; }
        .user-list { background: #1a1a1a; border: 1px solid #333; border-radius: 12px; overflow-y: auto; }
        .user-item { padding: 15px; border-bottom: 1px solid #333; cursor: pointer; transition: 0.2s; display: flex; justify-content: space-between; align-items: center; }
        .user-item:hover, .user-item.active { background: #333; }
        .chat-area { background: #1a1a1a; border: 1px solid #333; border-radius: 12px; display: flex; flex-direction: column; overflow: hidden; }
        .chat-messages { flex: 1; padding: 20px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; }
        .chat-input-area { padding: 15px; border-top: 1px solid #333; display: flex; gap: 10px; background: #222; }
        
        .msg { padding: 8px 12px; border-radius: 8px; max-width: 70%; font-size: 0.9rem; word-wrap: break-word; }
        .msg.admin { align-self: flex-end; background: var(--accent); color: #000; border-bottom-right-radius: 0; }
        .msg.user { align-self: flex-start; background: #333; color: #fff; border-bottom-left-radius: 0; }

        /* MODAL & TOAST */
        .custom-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); backdrop-filter: blur(5px); z-index: 2000; align-items: center; justify-content: center; animation: fadeIn 0.2s; }
        .modal-box { background: #1a1a1a; padding: 30px; border-radius: 20px; width: 90%; max-width: 400px; border: 1px solid #333; text-align: center; box-shadow: 0 0 30px rgba(204, 255, 0, 0.2); transform: scale(0.9); animation: popUp 0.3s forwards; }
        @keyframes popUp { to { transform: scale(1); } }
        .modal-title { font-size: 1.2rem; margin-bottom: 10px; color: #fff; }
        .modal-desc { color: #888; margin-bottom: 25px; font-size: 0.95rem; }
        .modal-actions { display: flex; gap: 10px; justify-content: center; }
        .btn-cancel { background: #333; color: #fff; padding: 12px 25px; border-radius: 50px; border: none; cursor: pointer; font-weight: bold; }
        .btn-confirm { background: var(--accent); color: #000; padding: 12px 25px; border-radius: 50px; border: none; cursor: pointer; font-weight: bold; box-shadow: 0 0 10px rgba(204, 255, 0, 0.3); }

        .admin-toast { position: fixed; bottom: 30px; right: 30px; background: #1a1a1a; border-left: 4px solid var(--accent); color: #fff; padding: 15px 25px; border-radius: 12px; box-shadow: 0 5px 20px rgba(0,0,0,0.5); display: flex; align-items: center; gap: 10px; transform: translateY(100px); transition: 0.4s; z-index: 3000; }
        .admin-toast.show { transform: translateY(0); }

        .menu-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }
        @media (max-width: 768px) {
            .sidebar { position: fixed; left: -260px; top: 0; bottom: 0; height: 100vh; box-shadow: 5px 0 15px rgba(0,0,0,0.5); }
            .sidebar.active { left: 0; }
            .overlay.active { display: block; }
            .hamburger { display: block; }
            .main-content { padding: 20px; width: 100%; }
            .menu-grid { grid-template-columns: 1fr; }
            h1#total-revenue-text { font-size: 2.5rem !important; }
            .custom-select { width: 100%; margin-top: 10px; }
            #tab-dashboard > div, #tab-orders > div { flex-direction: column; align-items: flex-start !important; gap: 10px; }
            .chart-container { height: 250px; }
            .chat-layout { grid-template-columns: 1fr; height: auto; }
            .user-list { height: 150px; margin-bottom: 10px; }
            .chat-area { height: 400px; }
        }
    </style>
</head>
<body>

    <div id="confirmModal" class="custom-modal">
        <div class="modal-box">
            <h3 class="modal-title">Konfirmasi Aksi ⚠️</h3>
            <p class="modal-desc" id="modalDesc">Yakin mau ubah status?</p>
            <div class="modal-actions">
                <button class="btn-cancel" onclick="closeConfirm()">Batal</button>
                <button class="btn-confirm" id="btnYes">GAS UBAH! 🚀</button>
            </div>
        </div>
    </div>

    <div id="adminToast" class="admin-toast"><span style="font-size: 1.2rem;">✅</span><span id="toastMsg">Berhasil!</span></div>
    <div class="overlay" onclick="toggleSidebar()"></div>

    <nav class="sidebar" id="sidebar">
        <div class="brand">MAKANCUY.</div>
        <a onclick="switchTab('dashboard')" class="nav-link active" id="link-dashboard"><span class="nav-icon">📊</span> Dashboard</a>
        <a onclick="switchTab('orders')" class="nav-link" id="link-orders"><span class="nav-icon">📦</span> Kelola Pesanan</a>
        <a onclick="switchTab('chat')" class="nav-link" id="link-chat"><span class="nav-icon">💬</span> Live Chat <span class="badge" id="chatBadge">!</span></a>
        <a onclick="switchTab('history')" class="nav-link" id="link-history"><span class="nav-icon">📜</span> Riwayat</a>
        <a onclick="switchTab('menu')" class="nav-link" id="link-menu"><span class="nav-icon">🍔</span> Menu</a>
        <div class="user-info">Login as: <b><%= user.getUsername() %></b><br><br><a href="./" style="color:#888;text-decoration:none;">➜ Web Utama</a><br><a href="auth" style="color:#ff4757;text-decoration:none;">✖ Logout</a></div>
    </nav>

    <main class="main-content">
        <button class="hamburger" onclick="toggleSidebar()">☰ Menu Admin</button>

        <div id="tab-dashboard" class="tab-section active">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:30px;">
                <h2 style="margin:0;">Overview</h2>
                <select id="dashboard-filter" class="custom-select" onchange="loadDashboard()"><option value="today">Hari Ini</option><option value="week">Minggu Ini</option><option value="month">Bulan Ini</option><option value="all">Semua</option></select>
            </div>
            <div class="card card-highlight"><small style="color:#888;">PENDAPATAN</small><h1 id="total-revenue-text" style="color:var(--accent); font-size:3.5rem; margin:10px 0;">Rp 0</h1></div>
            <div class="card"><h3>Grafik Penjualan</h3><div class="chart-container"><canvas id="salesChart"></canvas></div></div>
        </div>

        <div id="tab-orders" class="tab-section">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
                <h2 style="margin:0;">Dapur & Operasional 👨‍🍳</h2>
                <select id="orders-filter" class="custom-select" onchange="loadOrders()"><option value="today">Hari Ini</option><option value="week">Minggu Ini</option><option value="all">Semua</option></select>
            </div>
            <div id="orders-container" class="order-grid"><p>Memuat data pesanan...</p></div>
        </div>

        <div id="tab-chat" class="tab-section">
            <h2 style="margin-bottom:20px;">Live Chat Support 💬</h2>
            <div class="chat-layout">
                <div class="user-list" id="chatUserList">
                    <p style="padding:15px; color:#666">Memuat user...</p>
                </div>
                
                <div class="chat-area">
                    <div id="chatActiveUser" style="padding:10px; background:#222; border-bottom:1px solid #333; font-weight:bold; display:none;">
                        Chatting with: <span id="activeUserName" style="color:var(--accent)">-</span>
                    </div>

                    <div class="chat-messages" id="adminChatBody">
                        <div style="text-align:center; color:#555; margin-top:50px;">Pilih user di kiri untuk mulai chat.</div>
                    </div>
                    
                    <div class="chat-input-area" id="adminChatInputArea" style="display:none;">
                        <input type="text" id="adminChatInput" placeholder="Balas pesan..." style="margin:0; background:#333;" onkeypress="handleAdminChatEnter(event)">
                        <button class="btn" style="background:var(--accent); color:#000;" onclick="adminSendChat()">Kirim</button>
                    </div>
                </div>
            </div>
        </div>

        <div id="tab-history" class="tab-section">
            <div style="display:flex; gap:10px; margin-bottom:20px;">
                <button onclick="downloadPDF()" class="btn" style="background:#e74c3c; color:#fff;">📄 Download PDF</button>
                <button onclick="downloadExcel()" class="btn" style="background:#27ae60; color:#fff;">📊 Download Excel</button>
            </div>
            <div class="card"><div class="table-responsive"><table><thead><tr><th>ID</th><th>Tanggal</th><th>Pelanggan</th><th>Status</th><th>Total</th></tr></thead><tbody id="table-history-body"></tbody></table></div></div>
        </div>

        <div id="tab-menu" class="tab-section">
            <div class="menu-grid">
                <div class="card"><h3>Daftar Menu</h3><div class="table-responsive"><table><thead><tr><th>Menu</th><th>Harga</th><th>Aksi</th></tr></thead><tbody><c:forEach items="${adminMenu}" var="m"><tr><td><b>${m.name}</b><br><small style="color:#888">${m.category}</small></td><td>Rp <fmt:formatNumber value="${m.price}" maxFractionDigits="0"/></td><td><a href="admin?action=delete&id=${m.id}" onclick="return confirm('Hapus menu ini?')" style="color:#ff4757; text-decoration:none;">Hapus</a></td></tr></c:forEach></tbody></table></div></div>
                <div class="card"><h3>➕ Tambah Menu</h3><form action="admin" method="post"><input type="hidden" name="action" value="add_menu"><input type="text" name="name" required placeholder="Nama Menu"><input type="number" name="price" required placeholder="Harga"><select name="category"><option>Makanan</option><option>Minuman</option><option>Cemilan</option></select><input type="text" name="image" placeholder="URL Gambar" required><textarea name="description" placeholder="Deskripsi Singkat"></textarea><button type="submit" class="btn btn-primary">SIMPAN MENU</button></form></div>
            </div>
        </div>
    </main>

    <script>
        let myChartInstance = null;
        const API_URL = '<%= request.getContextPath() %>/api/admin-stats';
        let laporanData = []; let totalPendapatanText = "0";

        // --- 1. MODAL & ORDER LOGIC ---
        let pendingId = null; let pendingStatus = null; let pendingSelectElement = null;

        function openConfirm(id, status, selectElement) {
            pendingId = id; pendingStatus = status; pendingSelectElement = selectElement;
            let statusText = "";
            if(status === 'PROCESSING') statusText = "🔥 Proses Masak";
            else if(status === 'DELIVERING') statusText = "🛵 Antar Pesanan";
            else if(status === 'COMPLETED') statusText = "✅ Selesai";
            else if(status === 'REJECTED') statusText = "❌ Tolak";

            document.getElementById('modalDesc').innerHTML = 'Ubah status pesanan <b>#' + id + '</b> jadi <b style="color:var(--accent)">' + statusText + '</b>?';
            document.getElementById('btnYes').onclick = processUpdate;
            document.getElementById('confirmModal').style.display = 'flex';
        }

        function closeConfirm() {
            document.getElementById('confirmModal').style.display = 'none';
            if (pendingSelectElement) { pendingSelectElement.value = "default"; loadOrders(); }
            pendingId = null; pendingStatus = null; pendingSelectElement = null;
        }

        function processUpdate() {
            if (!pendingId || !pendingStatus) return;
            const formData = new URLSearchParams();
            formData.append('action', 'update_status');
            formData.append('id', pendingId);
            formData.append('status', pendingStatus);

            fetch('admin', { method: 'POST', body: formData }).then(res => {
                if (res.ok) {
                    document.getElementById('confirmModal').style.display = 'none';
                    showAdminToast("Status Order #" + pendingId + " Berhasil!");
                    loadOrders(); loadDashboard(); loadHistory();
                } else { alert("Gagal update!"); }
            }).catch(err => console.error(err));
        }

        function showAdminToast(msg) {
            const toast = document.getElementById('adminToast');
            document.getElementById('toastMsg').innerText = msg;
            toast.classList.add('show'); setTimeout(() => { toast.classList.remove('show'); }, 2000);
        }

        // --- 2. LOAD ORDERS (WITH NOTES & DISCOUNT) ---
        async function loadOrders() {
            const filter = document.getElementById('orders-filter').value;
            const container = document.getElementById('orders-container');
            
            try {
                const res = await fetch(API_URL + '?filter=' + filter);
                const data = await res.json();
                container.innerHTML = '';

                if (!data.history || data.history.length === 0) {
                    container.innerHTML = '<p style="color:#666">Tidak ada pesanan aktif.</p>'; return;
                }

                data.history.forEach(function(order) {
                    if (['PAID', 'PROCESSING', 'DELIVERING'].includes(order.status)) {
                        let badge = ''; let cardClass = 'order-card';
                        if (order.status === 'PAID') { badge = '<span class="status-badge status-paid">BARU</span>'; cardClass += ' priority'; } 
                        else if (order.status === 'PROCESSING') { badge = '<span class="status-badge status-process">DIMASAK</span>'; } 
                        else if (order.status === 'DELIVERING') { badge = '<span class="status-badge" style="background:#f59e0b; color:#000">DIANTAR</span>'; }

                        let itemsHtml = '';
                        if (order.itemsDesc && order.itemsDesc.length > 0) {
                            order.itemsDesc.split(', ').forEach(item => { itemsHtml += '<div class="item-row"><span>' + item + '</span></div>'; });
                        } else { itemsHtml = 'Detail kosong'; }

                        // Cek Catatan
                        let notesHtml = '';
                        if (order.notes && order.notes.trim() !== '') {
                            notesHtml = '<div class="order-note">📝 "' + order.notes + '"</div>';
                        }

                        let html = 
                            '<div class="' + cardClass + '">' +
                                '<div class="order-header"><span style="font-weight:bold; color:var(--accent)">#' + order.id + '</span><span style="font-size:0.8rem; color:#888">' + order.date.substring(5, 16) + '</span></div>' +
                                '<div style="margin-bottom:15px;"><strong>' + order.username + '</strong> ' + badge + '</div>' +
                                '<div class="order-items">' + itemsHtml + '</div>' +
                                notesHtml + 
                                '<div style="margin-bottom:10px; font-weight:bold; text-align:right; border-top:1px dashed #444; padding-top:5px;">Total: Rp ' + order.total.toLocaleString("id-ID") + '</div>' +
                                '<div class="action-container">' +
                                    '<select class="status-select" onchange="openConfirm(' + order.id + ', this.value, this)">' +
                                        '<option value="default" disabled selected>⚡ Pilih Aksi...</option>' +
                                        '<option value="PROCESSING">🔥 Proses Masak</option>' +
                                        '<option value="DELIVERING">🛵 Antar Pesanan</option>' +
                                        '<option value="COMPLETED">✅ Pesanan Selesai</option>' +
                                        '<option value="REJECTED">❌ Tolak Pesanan</option>' +
                                    '</select>' +
                                '</div>' +
                            '</div>';
                        container.innerHTML += html;
                    }
                });
            } catch (err) { console.error("Order Load Error:", err); }
        }

        // --- 3. LIVE CHAT SYSTEM (REALTIME) ---
        let activeChatUserId = null;

        // Load List User yang Chat
        function loadChatUsers() {
            fetch('chat?action=list_users').then(r=>r.json()).then(data => {
                const list = document.getElementById('chatUserList');
                let html = '';
                if(data.length === 0) html = '<p style="padding:15px; color:#666">Belum ada chat.</p>';
                else {
                    document.getElementById('chatBadge').style.display = 'inline-block'; // Show badge
                }
                
                data.forEach(u => {
                    let activeClass = (u.id == activeChatUserId) ? 'active' : '';
                    html += `<div class="user-item `+activeClass+`" onclick="openChat(`+u.id+`, '`+u.username+`')">
                                <div><b>`+u.username+`</b></div>
                                <span style="font-size:0.8rem">ID: `+u.id+`</span>
                             </div>`;
                });
                list.innerHTML = html;
            });
        }

        function openChat(userId, username) {
            activeChatUserId = userId;
            document.getElementById('activeUserName').innerText = username;
            document.getElementById('chatActiveUser').style.display = 'block';
            document.getElementById('adminChatInputArea').style.display = 'flex';
            loadAdminMessages();
        }

        function loadAdminMessages() {
            if(!activeChatUserId) return;
            fetch('chat?action=get_messages&user_id=' + activeChatUserId).then(r=>r.json()).then(data => {
                const body = document.getElementById('adminChatBody');
                let html = '';
                if(data.length === 0) html = '<p style="text-align:center;color:#555">Belum ada riwayat pesan.</p>';
                
                data.forEach(msg => {
                    let cls = (msg.sender === 'admin') ? 'admin' : 'user';
                    html += `<div class="msg `+cls+`">`+msg.message+`</div>`;
                });
                body.innerHTML = html;
            });
        }

        function handleAdminChatEnter(e) { if(e.key === 'Enter') adminSendChat(); }

        function adminSendChat() {
            const input = document.getElementById('adminChatInput');
            const msg = input.value;
            if(!msg || !activeChatUserId) return;

            const formData = new URLSearchParams();
            formData.append('action', 'send');
            formData.append('message', msg);
            formData.append('target_id', activeChatUserId);

            fetch('chat', { method: 'POST', body: formData }).then(() => {
                input.value = "";
                loadAdminMessages();
            });
        }

        // --- 4. UTILS & INIT ---
        async function loadDashboard() {
            const filter = document.getElementById('dashboard-filter').value;
            try {
                const res = await fetch(API_URL + '?filter=' + filter);
                const data = await res.json();
                document.getElementById('total-revenue-text').innerText = new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(data.totalRevenue);
                renderChart(data.history);
            } catch (err) {}
        }

        function renderChart(historyData) {
            const ctx = document.getElementById('salesChart'); if (!ctx) return;
            if (myChartInstance) myChartInstance.destroy();
            const sortedData = [...historyData].reverse();
            myChartInstance = new Chart(ctx, {
                type: 'line',
                data: { labels: sortedData.map(i => i.date.split(' ')[0]), datasets: [{ label: 'Pendapatan', data: sortedData.map(i => i.total), borderColor: '#ccff00', backgroundColor: 'rgba(204, 255, 0, 0.2)', borderWidth: 2, tension: 0.4, fill: true, pointRadius: 4, pointBackgroundColor: '#fff' }] },
                options: { responsive: true, maintainAspectRatio: false, scales: { y: { beginAtZero: true, grid: { color: '#333' }, ticks: { color: '#888' } }, x: { grid: { color: '#333' }, ticks: { color: '#888' } } }, plugins: { legend: { labels: { color: '#fff' } } } }
            });
        }

        async function loadHistory() {
            try {
                const res = await fetch(API_URL + '?filter=all');
                const data = await res.json();
                laporanData = data.history; totalPendapatanText = new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(data.totalRevenue);
                const tbody = document.getElementById('table-history-body'); tbody.innerHTML = '';
                data.history.forEach(i => {
                    let badge = i.status;
                    if(i.status == 'COMPLETED') badge = '<span style="color:#ccff00">Selesai</span>';
                    else if(i.status == 'REJECTED') badge = '<span style="color:#f87171">Ditolak</span>';
                    tbody.innerHTML += '<tr><td>#' + i.id + '</td><td>' + i.date + '</td><td>' + i.username + '</td><td>' + badge + '</td><td>Rp ' + i.total.toLocaleString('id-ID') + '</td></tr>';
                });
            } catch (err) {}
        }

        function downloadPDF() {
            const { jsPDF } = window.jspdf; const doc = new jsPDF();
            doc.setFontSize(18); doc.text("Laporan Penjualan MakanCuy", 14, 20);
            doc.setFontSize(11); doc.text("Total Pendapatan: " + totalPendapatanText, 14, 30);
            doc.autoTable({ startY: 40, html: '#table-history-body', head: [['ID', 'Tanggal', 'User', 'Status', 'Total']], theme: 'grid' });
            doc.save('Laporan_MakanCuy.pdf');
        }

        function downloadExcel() {
            if (laporanData.length === 0) { alert("Data kosong"); return; }
            const ws = XLSX.utils.json_to_sheet(laporanData.map(i => ({ "ID": i.id, "User": i.username, "Total": i.total, "Status": i.status })));
            const wb = XLSX.utils.book_new(); XLSX.utils.book_append_sheet(wb, ws, "Laporan");
            XLSX.writeFile(wb, 'Laporan_MakanCuy.xlsx');
        }

        function toggleSidebar() { document.getElementById('sidebar').classList.toggle('active'); document.querySelector('.overlay').classList.toggle('active'); }
        function switchTab(name) { document.querySelectorAll('.tab-section').forEach(el => el.classList.remove('active')); document.querySelectorAll('.nav-link').forEach(el => el.classList.remove('active')); document.getElementById('tab-' + name).classList.add('active'); document.getElementById('link-' + name).classList.add('active'); if (name === 'dashboard') loadDashboard(); if (name === 'orders') loadOrders(); if (name === 'history') loadHistory(); if(window.innerWidth <= 768) toggleSidebar(); }

        window.onload = function() {
            if(window.innerWidth <= 768) document.querySelector('.hamburger').style.display = 'block';
            switchTab('dashboard'); 
            // Polling Interval
            setInterval(function() { 
                if(document.getElementById('tab-orders').classList.contains('active')) loadOrders(); 
                // Always check chat users for badge
                loadChatUsers();
                // If chat tab open, load messages
                if(document.getElementById('tab-chat').classList.contains('active') && activeChatUserId) loadAdminMessages();
            }, 3000);
        };
    </script>
</body>
</html>