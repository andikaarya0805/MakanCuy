<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard - MakanCuy</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    <style>
        /* BASE STYLE */
        :root { --bg: #0d0d0d; --card: #1a1a1a; --accent: #ccff00; --text: #fff; --font: 'Space Grotesk', sans-serif; }
        body { background: var(--bg); color: var(--text); font-family: var(--font); padding: 20px; }
        .container { max-width: 1000px; margin: 0 auto; }

        /* DASHBOARD HEADER */
        .dashboard-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 1px solid #333; padding-bottom: 20px; }
        
        /* STATS CARD */
        .stats-card { background: var(--card); padding: 25px; border: 1px solid var(--accent); border-radius: 15px; display: inline-block; min-width: 250px; }
        .stats-num { font-size: 2.5rem; font-weight: bold; color: var(--accent); margin: 10px 0; }
        
        /* TABLE */
        .table-container { overflow-x: auto; margin-top: 20px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #333; }
        th { color: var(--accent); text-transform: uppercase; font-size: 0.9rem; letter-spacing: 1px; }
        tr:hover { background: #222; }
        
        /* BUTTONS */
        .btn { padding: 10px 20px; border-radius: 8px; border: none; font-weight: bold; cursor: pointer; transition: 0.2s; text-decoration: none; color: #000; display: inline-block; }
        .btn:hover { opacity: 0.8; }
        .btn-add { background: var(--accent); width: 100%; margin-top: 10px; }
        .btn-del { background: #ff4757; color: #fff; padding: 6px 12px; font-size: 0.8rem; border-radius: 4px; }
        .btn-print { background: #fff; color: #000; }
        .btn-home { background: transparent; color: #fff; border: 1px solid #fff; margin-right: 10px;}

        /* FORM */
        .add-form { background: var(--card); padding: 30px; border-radius: 15px; margin-top: 50px; border: 1px dashed #555; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; color: #aaa; font-size: 0.9rem; }
        input, select, textarea { width: 100%; padding: 12px; background: #000; border: 1px solid #333; color: #fff; border-radius: 8px; font-family: var(--font); }
        
        /* PRINT MODE */
        @media print {
            body { background: #fff; color: #000; }
            .no-print, .add-form, .btn-del, .btn-print, .btn-home { display: none !important; }
            .stats-card { border: 2px solid #000; color: #000; background: none; }
            .stats-num { color: #000; }
            table { border: 1px solid #000; width: 100%; }
            th, td { border-bottom: 1px solid #000; color: #000; }
        }
    </style>
</head>
<body>

    <div class="container">
        <div class="dashboard-header">
            <div>
                <h1>Admin Dashboard ⚙️</h1>
                <p style="color: var(--accent)">Halo, ${currentUser}!</p> 
            </div>
            <div class="no-print">
                <a href="./" class="btn btn-home">Web Utama</a>
                <a href="auth" class="btn" style="background: #333; color: #fff; font-size: 0.9rem; margin-right: 10px;">Logout ➜</a>
                <button onclick="window.print()" class="btn btn-print">🖨️ Cetak</button>
            </div>
        </div>

        <div class="card">
    <h3>TOTAL PENDAPATAN (SALES)</h3>
    <h1 style="color: var(--accent-green); font-size: 3rem; margin: 10px 0;">
        <fmt:setLocale value="id_ID"/>
        <fmt:formatNumber value="${totalSales}" type="currency" currencySymbol="Rp " maxFractionDigits="0"/>
    </h1>
    <p>Updated: Realtime</p>
</div>
        <h2 style="margin-top: 40px; border-left: 5px solid var(--accent); padding-left: 15px;">Laporan Stok Menu</h2>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Menu</th>
                        <th>Harga</th>
                        <th>Kategori</th>
                        <th class="no-print">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${adminMenu}" var="m">
                        <tr>
                            <td>#${m.id}</td>
                            <td>
                                <strong>${m.name}</strong><br>
                                <small style="color: #aaa">${m.description}</small>
                            </td>
                            <td>Rp <fmt:formatNumber value="${m.price}" maxFractionDigits="0"/></td>
                            <td>${m.category}</td>
                            <td class="no-print">
                                <a href="admin?action=delete&id=${m.id}" class="btn btn-del" onclick="return confirm('Hapus menu ini?')">Hapus</a>
                            </td>
                        </tr>
                    </c:forEach>
                    
                    <c:if test="${empty adminMenu}">
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 30px;">Belum ada menu nih. Tambah di bawah ya! 👇</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
        </div>

        <div class="add-form no-print">
            <h3 style="margin-bottom: 20px;">➕ Input Menu Baru</h3>
            <form action="admin" method="post">
                <div class="form-grid">
                    <div class="form-group">
                        <label>Nama Makanan</label>
                        <input type="text" name="name" required>
                    </div>
                    <div class="form-group">
                        <label>Harga (Angka)</label>
                        <input type="number" name="price" required>
                    </div>
                    <div class="form-group">
                        <label>Kategori</label>
                        <select name="category">
                            <option value="Makanan">Makanan</option>
                            <option value="Minuman">Minuman</option>
                            <option value="Cemilan">Cemilan</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>URL Gambar</label>
                        <input type="text" name="image" placeholder="https://..." required>
                    </div>
                </div>
                <div class="form-group">
                    <label>Deskripsi</label>
                    <textarea name="description" rows="2"></textarea>
                </div>
                <button type="submit" class="btn btn-add">SIMPAN KE DATABASE</button>
            </form>
        </div>

        <br><br><br>
    </div>

</body>
</html>