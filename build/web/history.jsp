<%-- 
    Document   : history
    Created on : Dec 28, 2025, 12:48:49 AM
    Author     : andik
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="com.makancuy.model.User" %>

<%
    // Cek Login Sederhana
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Riwayat Pesanan</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { background: #0d0d0d; color: white; font-family: sans-serif; }
        /* Animasi loading sederhana */
        .fade-in { animation: fadeIn 0.5s ease-in-out; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
    </style>
</head>
<body class="p-5">

    <div class="max-w-4xl mx-auto">
        <div class="flex justify-between items-center mb-6">
            <h1 class="text-2xl font-bold text-[#ccff00]">Riwayat Pesanan Saya</h1>
            <a href="index.jsp" class="text-gray-400 hover:text-white">Kembali ke Menu</a>
        </div>

        <div id="order-container">
            <p class="text-center text-gray-500 mt-10">Memuat data...</p>
        </div>

    </div>

    <script>
        async function fetchHistory() {
            const container = document.getElementById('order-container');
            const url = '<%= request.getContextPath() %>/api/my-history';

            try {
                const res = await fetch(url);
                if (res.status === 401) {
                    window.location.href = 'login.jsp'; 
                    return;
                }
                const data = await res.json();

                // 1. Cek jika data kosong
                if (data.length === 0) {
                    container.innerHTML = `
                        <div class="text-center py-10 text-gray-500">
                            Belum ada riwayat pesanan.<br>
                            <a href="index.jsp" class="text-[#ccff00] underline">Pesan sekarang yuk!</a>
                        </div>
                    `;
                    return;
                }

                // 2. Susun HTML dalam variabel dulu (JANGAN SENTUH CONTAINER DULU)
                let newContent = '';

                data.forEach(o => {
                    let statusHtml = '';
                    
                    if (o.status === 'PAID') {
                        statusHtml = 
                            '<span class="bg-yellow-500/20 text-yellow-500 px-3 py-1 rounded-full text-sm font-bold border border-yellow-500">' +
                                '⏳ Menunggu Konfirmasi' +
                            '</span>' +
                            '<p class="text-xs text-gray-400 mt-2">Mohon tunggu admin mengecek pembayaran.</p>';
                    } else if (o.status === 'PROCESSING') {
                        statusHtml = 
                            '<span class="bg-green-500/20 text-green-400 px-3 py-1 rounded-full text-sm font-bold border border-green-500">' +
                                '✅ Pembayaran Diterima' +
                            '</span>' +
                            '<div class="mt-2 bg-green-900/30 p-2 rounded text-xs text-green-200 border border-green-800">' +
                                'Pesanan sedang disiapkan dapur!<br>Mohon ditunggu ya kak.' +
                            '</div>';
                    } else if (o.status === 'REJECTED') {
                        statusHtml = 
                            '<span class="bg-red-500/20 text-red-500 px-3 py-1 rounded-full text-sm font-bold border border-red-500">' +
                                '❌ Ditolak' +
                            '</span>' +
                            '<p class="text-xs text-red-400 mt-2">Bukti pembayaran tidak valid / Stok habis.</p>';
                    } else {
                        statusHtml = '<span class="text-gray-500 border border-gray-600 px-3 py-1 rounded-full text-sm">' + o.status + '</span>';
                    }

                    // Tambahkan ke variabel string
                    newContent += 
                        '<div class="bg-[#1a1a1a] p-5 rounded-lg border border-[#333] mb-4">' +
                            '<div class="flex justify-between items-start">' +
                                '<div>' +
                                    '<h3 class="text-lg font-bold">Order #' + o.id + '</h3>' +
                                    '<p class="text-sm text-gray-500">' + o.date + '</p>' +
                                    '<p class="mt-2">Metode: <span class="uppercase">' + o.method + '</span></p>' +
                                    '<p class="text-xl font-bold mt-1">Rp ' + o.total.toLocaleString('id-ID') + '</p>' +
                                '</div>' +
                                '<div class="text-right">' +
                                    statusHtml +
                                '</div>' +
                            '</div>' +
                        '</div>';
                });

                // 3. BARU UPDATE LAYAR (Sekali Update, Gak Kedip)
                // Kita cek dulu biar gak update kalau kontennya sama persis (Optimasi tambahan)
                if (container.innerHTML !== newContent) {
                    container.innerHTML = newContent;
                }

            } catch (err) {
                console.error("Gagal ambil data:", err);
            }
        }

        // Jalanin pas awal buka
        fetchHistory();

        // Jalanin ulang setiap 3 detik
        setInterval(fetchHistory, 1000);
    </script>
</body>
</html>