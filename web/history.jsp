<%-- 
    Document   : history
    Created on : Dec 20, 2025, 5:29:12 PM
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
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"> 
    <title>Riwayat Pesanan</title>
    
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">

    <style>
        body { background: #0d0d0d; color: white; font-family: 'Space Grotesk', sans-serif; }
        .fade-in { animation: fadeIn 0.5s ease-in-out; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-thumb { background: #333; border-radius: 10px; }
    </style>
</head>
<body class="p-4 sm:p-8">

    <div class="max-w-3xl mx-auto">
        <div class="flex flex-col sm:flex-row justify-between items-center mb-8 gap-4 text-center sm:text-left">
            <h1 class="text-3xl font-bold text-[#ccff00] tracking-tight">Riwayat Jajan</h1>
            <a href="index.jsp" class="text-gray-400 hover:text-white transition bg-[#1a1a1a] px-4 py-2 rounded-full border border-[#333] text-sm">
                ← Kembali ke Menu
            </a>
        </div>

        <div id="order-container" class="space-y-4">
            <p class="text-center text-gray-500 mt-10 animate-pulse">Sedang memuat data...</p>
        </div>
    </div>

    <script>
        async function fetchHistory() {
            const container = document.getElementById('order-container');
            const url = '<%= request.getContextPath() %>/api/my-history';

            try {
                const res = await fetch(url);
                if (res.status === 401) { window.location.href = 'login.jsp'; return; }
                
                const data = await res.json();

                // 1. KOSONG
                if (data.length === 0) {
                    container.innerHTML = 
                        '<div class="text-center py-20 text-gray-500 border border-dashed border-[#333] rounded-xl">' +
                            '<p class="text-lg">Belum ada riwayat pesanan.</p>' +
                            '<a href="index.jsp" class="text-[#ccff00] font-bold mt-2 inline-block border-b border-[#ccff00]">Pesan sekarang yuk! 🚀</a>' +
                        '</div>';
                    return;
                }

                // 2. RENDER CARD (GAYA AMAN: CONCATENATION +)
                let newContent = '';

                data.forEach(function(o) {
                    let statusHtml = '';
                    let statusClass = '';
                    let statusIcon = '';
                    let desc = '';

                    // Logic Status
                    if (o.status === 'PAID') {
                        statusClass = 'text-yellow-400 border-yellow-500/50 bg-yellow-500/10';
                        statusIcon = '⏳';
                        statusHtml = 'Menunggu Konfirmasi';
                        desc = 'Admin lagi cek pembayaran kamu.';
                    } else if (o.status === 'PROCESSING') {
                        statusClass = 'text-blue-400 border-blue-500/50 bg-blue-500/10';
                        statusIcon = '🔥';
                        statusHtml = 'Sedang Dimasak';
                        desc = 'Sabar ya, koki lagi beraksi!';
                    } else if (o.status === 'DELIVERING') {
                        statusClass = 'text-orange-400 border-orange-500/50 bg-orange-500/10';
                        statusIcon = '🛵';
                        statusHtml = 'Sedang Diantar';
                        desc = 'Makananmu lagi OTW ke meja.';
                    } else if (o.status === 'COMPLETED') {
                        statusClass = 'text-[#ccff00] border-[#ccff00]/50 bg-[#ccff00]/10';
                        statusIcon = '✅';
                        statusHtml = 'Selesai';
                        desc = 'Terima kasih sudah jajan!';
                    } else if (o.status === 'REJECTED') {
                        statusClass = 'text-red-400 border-red-500/50 bg-red-500/10';
                        statusIcon = '❌';
                        statusHtml = 'Dibatalkan';
                        desc = 'Pesanan ditolak/dibatalkan.';
                    }

                    // Logic Tombol Invoice (Biar aman dari JSP)
                    let btnInvoice = '';
                    if (o.status === 'COMPLETED') {
                        btnInvoice = '<a href="invoice?id=' + o.id + '" class="inline-block mt-2 text-xs bg-[#333] hover:bg-[#444] text-white px-3 py-1.5 rounded-lg border border-gray-600 transition">📄 Cetak Struk</a>';
                    }

                    // Susun HTML pake kutip satu (') dan plus (+)
                    newContent += 
                        '<div class="bg-[#1a1a1a] rounded-xl border border-[#333] overflow-hidden hover:border-[#555] transition shadow-lg">' +
                            
                            // Header
                            '<div class="bg-[#222] px-5 py-3 flex justify-between items-center border-b border-[#333]">' +
                                '<span class="font-mono text-gray-400 text-sm">#' + o.id + '</span>' +
                                '<span class="text-xs text-gray-500">' + o.date + '</span>' +
                            '</div>' +

                            // Body
                            '<div class="p-5 flex flex-col sm:flex-row justify-between gap-4">' +
                                
                                // Kiri
                                '<div>' +
                                    '<p class="text-xs text-gray-400 uppercase tracking-widest mb-1">' + o.method + '</p>' +
                                    '<p class="text-2xl font-bold text-white mb-2">Rp ' + o.total.toLocaleString("id-ID") + '</p>' +
                                    btnInvoice +
                                '</div>' +

                                // Kanan
                                '<div class="text-left sm:text-right">' +
                                    '<span class="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg text-sm font-bold border ' + statusClass + '">' +
                                        '<span>' + statusIcon + '</span> ' + statusHtml +
                                    '</span>' +
                                    '<p class="text-xs text-gray-400 mt-2 max-w-[200px] sm:ml-auto leading-relaxed">' +
                                        desc +
                                    '</p>' +
                                '</div>' +

                            '</div>' +
                        '</div>';
                });

                // Update cuma kalau ada perubahan (biar gak kedip)
                if (container.innerHTML !== newContent) {
                    container.innerHTML = newContent;
                }

            } catch (err) { console.error("Gagal ambil data:", err); }
        }

        fetchHistory();
        setInterval(fetchHistory, 1000); 
    </script>
</body>
</html>