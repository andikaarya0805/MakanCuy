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
    <title>Admin Dashboard Pro - MakanCuy</title>
    <script src="https://unpkg.com/html2pdf.js@0.10.1/dist/html2pdf.bundle.min.js"></script>
    <script src="https://unpkg.com/chart.js@4.4.0/dist/chart.umd.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    
    <style>
        :root { --bg: #0d0d0d; --sidebar: #111; --card: #1a1a1a; --accent: #ccff00; --text: #fff; --hover: #222; }
        * { box-sizing: border-box; }
        body { background: var(--bg); color: var(--text); font-family: 'Space Grotesk', sans-serif; margin: 0; display: flex; height: 100vh; overflow: hidden; }
        .sidebar { width: 260px; background: var(--sidebar); border-right: 1px solid #333; display: flex; flex-direction: column; padding: 20px; flex-shrink: 0; }
        .brand { font-size: 1.5rem; font-weight: bold; color: var(--accent); margin-bottom: 40px; text-transform: uppercase; letter-spacing: 2px; }
        .nav-link { display: flex; align-items: center; padding: 15px; color: #888; text-decoration: none; margin-bottom: 5px; border-radius: 10px; transition: 0.3s; cursor: pointer; }
        .nav-link:hover { background: var(--hover); color: #fff; }
        .nav-link.active { background: var(--accent); color: #000; font-weight: bold; }
        .nav-icon { margin-right: 15px; font-size: 1.2rem; }
        .main-content { flex: 1; padding: 30px; overflow-y: auto; }
        .tab-section { display: none; animation: fadeIn 0.4s; }
        .tab-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .card { background: var(--card); padding: 25px; border: 1px solid #333; border-radius: 15px; margin-bottom: 20px; }
        .card-highlight { border-color: var(--accent); }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #333; vertical-align: middle; }
        th { color: var(--accent); text-transform: uppercase; font-size: 0.8rem; }
        .btn { padding: 10px 20px; border-radius: 8px; border: none; font-weight: bold; cursor: pointer; text-decoration: none; font-size: 0.9rem; }
        .btn-primary { background: var(--accent); color: #000; width: 100%; margin-top: 10px; }
        .custom-select { background: #000; color: #fff; border: 1px solid var(--accent); padding: 10px; border-radius: 8px; font-weight: bold; cursor: pointer; }
        input, select, textarea { width: 100%; padding: 12px; background: #000; border: 1px solid #333; color: #fff; margin-bottom: 15px; border-radius: 8px; font-family: inherit; }
        .chart-container { position: relative; height: 300px; width: 100%; }
        .user-info { margin-top: auto; padding-top: 20px; border-top: 1px solid #333; font-size: 0.9rem; color: #555; }
        
        /* CSS Tambahan untuk Badge Status */
        .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 0.8rem; border: 1px solid; display: inline-block; }
        .status-paid { color: #facc15; border-color: #facc15; background: rgba(250, 204, 21, 0.1); }
        .status-process { color: #4ade80; border-color: #4ade80; background: rgba(74, 222, 128, 0.1); }
        .status-reject { color: #f87171; border-color: #f87171; background: rgba(248, 113, 113, 0.1); }
    </style>
</head>
<body>

    <nav class="sidebar">
        <div class="brand">MAKANCUY.</div>
        <a onclick="switchTab('dashboard')" class="nav-link active" id="link-dashboard"><span class="nav-icon">📊</span> Dashboard</a>
        <a onclick="switchTab('history')" class="nav-link" id="link-history"><span class="nav-icon">📜</span> Riwayat Transaksi</a>
        <a onclick="switchTab('menu')" class="nav-link" id="link-menu"><span class="nav-icon">🍔</span> Manajemen Menu</a>

        <div class="user-info">
            Login as: <b style="color: #fff;"><%= user.getUsername() %></b><br><br>
            <a href="./" style="color: #888; text-decoration: none;">➜ Web Utama</a><br>
            <a href="auth" style="color: #ff4757; text-decoration: none;">✖ Logout</a>
        </div>
    </nav>

    <main class="main-content">
        
        <div id="tab-dashboard" class="tab-section active">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
                <h2>Overview Penjualan</h2>
                <select id="global-filter" class="custom-select" onchange="fetchData()">
                    <option value="all">Semua Waktu</option>
                    <option value="today">Hari Ini</option>
                    <option value="week">Minggu Ini</option>
                    <option value="month">Bulan Ini</option>
                </select>
            </div>
            <div class="card card-highlight">
                <small style="color: #888;">TOTAL PENDAPATAN</small>
                <h1 id="total-revenue-text" style="color: var(--accent); font-size: 3.5rem; margin: 10px 0;">Rp 0</h1>
            </div>
            <div class="card">
                <div class="chart-container"><canvas id="salesChart"></canvas></div>
            </div>
        </div>

        <div id="tab-history" class="tab-section">
            <div style="display: flex; justify-content: space-between; margin-bottom: 20px;">
                <h2>Laporan Transaksi</h2>
                <button onclick="downloadReport()" class="btn" style="background: #fff; color: #000;">📄 Download PDF</button>
            </div>
            <div class="card">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tanggal</th>
                            <th>Pelanggan</th>
                            <th>Status</th> <th>Total</th>
                            <th>Aksi</th>   </tr>
                    </thead>
                    <tbody id="table-history-body"></tbody>
                </table>
            </div>
        </div>

        <div id="tab-menu" class="tab-section">
            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px;">
                <div class="card">
                    <h3>Daftar Stok Menu</h3>
                    <table>
                        <thead>
                            <tr><th>Menu</th><th>Harga</th><th>Aksi</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${adminMenu}" var="m">
                                <tr>
                                    <td><b>${m.name}</b><br><small style="color:#888">${m.category}</small></td>
                                    <td>Rp <fmt:formatNumber value="${m.price}" maxFractionDigits="0"/></td>
                                    <td><a href="admin?action=delete&id=${m.id}" onclick="return confirm('Hapus menu ini?')" style="color: #ff4757; text-decoration:none;">Hapus</a></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <div class="card">
                    <h3>➕ Tambah Menu</h3>
                    <form action="admin" method="post">
                        <input type="hidden" name="action" value="add_menu"> <input type="text" name="name" required placeholder="Nama Menu">
                        <input type="number" name="price" required placeholder="Harga">
                        <select name="category">
                            <option value="Makanan">Makanan</option>
                            <option value="Minuman">Minuman</option>
                            <option value="Cemilan">Cemilan</option>
                        </select>
                        <input type="text" name="image" placeholder="URL Gambar" required>
                        <textarea name="description" placeholder="Deskripsi Singkat"></textarea>
                        <button type="submit" class="btn btn-primary">SIMPAN MENU</button>
                    </form>
                </div>
            </div>
        </div>
    </main>

    <script>
        let salesChart;

        async function fetchData() {
            const filterElement = document.getElementById('global-filter');
            const tbody = document.getElementById('table-history-body');
            const revenueText = document.getElementById('total-revenue-text');
            
            if (!filterElement || !tbody) return;

            const filter = filterElement.value;
            // Pastikan URL API ini benar. Kalau belum punya Servlet API, kode ini gak akan dapat data.
            const url = '<%= request.getContextPath() %>/api/admin-stats?filter=' + filter;
            
            try {
                const res = await fetch(url);
                if (!res.ok) throw new Error("API Error");
                const data = await res.json();

                // 1. Update Revenue
                revenueText.innerText = new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(data.totalRevenue);

                // 2. Update Table (PAKAI CARA AMAN "+" SUPAYA GAK BENTROK SAMA JSP)
                tbody.innerHTML = '';
                const labels = [];
                const values = [];

                if (!data.history || data.history.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="6" style="text-align:center; color:#555;">Belum ada data transaksi.</td></tr>';
                } else {
                    data.history.forEach(item => {
                        let statusBadge = '';
                        let actionButtons = '';

                        // Logic Badge Status
                        if (item.status === 'PAID') {
                            statusBadge = '<span class="status-badge status-paid">Menunggu Konfirmasi</span>';
                            actionButtons = 
                                '<div style="display:flex; gap:5px;">' +
                                    '<form action="admin" method="POST">' +
                                        '<input type="hidden" name="action" value="confirm">' +
                                        '<input type="hidden" name="id" value="' + item.id + '">' +
                                        '<button type="submit" class="btn" style="background:#4ade80; color:#000; padding:5px 10px; font-size:0.8rem;">✔ Terima</button>' +
                                    '</form>' +
                                    '<form action="admin" method="POST">' +
                                        '<input type="hidden" name="action" value="reject">' +
                                        '<input type="hidden" name="id" value="' + item.id + '">' +
                                        '<button type="submit" class="btn" style="background:#f87171; color:#fff; padding:5px 10px; font-size:0.8rem;">✖ Tolak</button>' +
                                    '</form>' +
                                '</div>';
                        } else if (item.status === 'PROCESSING') {
                            statusBadge = '<span class="status-badge status-process">Sedang Proses</span>';
                            actionButtons = '<span style="color:#4ade80; font-size:0.9rem;">✅ Disetujui</span>';
                        } else if (item.status === 'REJECTED') {
                            statusBadge = '<span class="status-badge status-reject">Ditolak</span>';
                            actionButtons = '<span style="color:#f87171; font-size:0.9rem;">❌ Ditolak</span>';
                        } else {
                            statusBadge = '<span class="status-badge" style="color:#888; border-color:#555;">' + item.status + '</span>';
                            actionButtons = '-';
                        }

                        // Render Baris (Concatenation Style)
                        tbody.innerHTML += 
                            '<tr>' +
                                '<td>#' + item.id + '</td>' +
                                '<td>' + item.date + '</td>' +
                                '<td>' +
                                    '<b>' + item.username + '</b><br>' +
                                    '<small style="color:#888">' + item.method + '</small>' +
                                '</td>' +
                                '<td>' + statusBadge + '</td>' +
                                '<td>Rp ' + item.total.toLocaleString('id-ID') + '</td>' +
                                '<td>' + actionButtons + '</td>' +
                            '</tr>';
                        
                        labels.unshift(item.date);
                        values.unshift(item.total);
                    });
                }

                // 3. Update Chart
                if (salesChart) {
                    salesChart.data.labels = labels;
                    salesChart.data.datasets[0].data = values;
                    salesChart.update();
                }
            } catch (err) { 
                console.error("Fetch Error:", err);
                // tbody.innerHTML = '<tr><td colspan="6" style="text-align:center;">Gagal memuat data API (Cek Console)</td></tr>';
            }
        }

        function initChart() {
            const ctx = document.getElementById('salesChart');
            if (!ctx) return;
            salesChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: [],
                    datasets: [{
                        label: 'Pendapatan (Rp)',
                        data: [],
                        borderColor: '#ccff00',
                        backgroundColor: 'rgba(204, 255, 0, 0.1)',
                        fill: true, tension: 0.3
                    }]
                },
                options: { 
                    responsive: true, maintainAspectRatio: false,
                    scales: { y: { beginAtZero: true, grid: { color: '#222' } }, x: { grid: { color: '#222' } } }
                }
            });
        }

        function switchTab(name) {
            const tabs = ['dashboard', 'history', 'menu'];
            tabs.forEach(tab => {
                const section = document.getElementById('tab-' + tab);
                const link = document.getElementById('link-' + tab);
                if (section && link) {
                    if (tab === name) {
                        section.classList.add('active');
                        link.classList.add('active');
                    } else {
                        section.classList.remove('active');
                        link.classList.remove('active');
                    }
                }
            });
            localStorage.setItem('activeTab', name);
        }

        function downloadReport() {
            const opt = { margin: 1, filename: 'Laporan_MakanCuy.pdf', image: { type: 'jpeg', quality: 0.98 }, html2canvas: { scale: 2 }, jsPDF: { unit: 'in', format: 'a4', orientation: 'landscape' } };
            const element = document.getElementById('tab-history');
            html2pdf().set(opt).from(element).save();
        }

        window.onload = () => {
            initChart();
            fetchData();
            setInterval(fetchData, 1000); 
            const lastTab = localStorage.getItem('activeTab') || 'dashboard';
            switchTab(lastTab);
        };
    </script>
</body>
</html>