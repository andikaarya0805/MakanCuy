<%-- 
    Document   : invoice
    Created on : Dec 20, 2025, 8:59:10 PM
    Author     : andik
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice #${orderId}</title>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono:ital,wght@0,400;0,700;1,400&display=swap" rel="stylesheet">
    
    <style>
        * { box-sizing: border-box; }

        body { 
            background: #222; 
            display: flex; 
            justify-content: center; 
            align-items: center; /* Tengah secara vertikal */
            min-height: 100vh; 
            margin: 0; 
            padding: 20px; /* Padding dikit biar gak nempel layar HP */
            font-family: 'Space Mono', monospace; 
        }
        
        .receipt {
            background: #fff; 
            width: 100%; 
            max-width: 380px; /* Batas lebar struk di laptop */
            padding: 25px; 
            color: #000;
            box-shadow: 0 0 30px rgba(0,0,0,0.5); 
            position: relative;
            /* Biar pas digenerate PDF gak kepotong */
            margin: auto; 
        }
        
        /* GERIGI KERTAS (Atas Bawah) */
        .receipt::before {
            content: ""; position: absolute; top: -6px; left: 0; width: 100%; height: 6px;
            background: linear-gradient(135deg, #fff 3px, transparent 0) 0 3px,
                        linear-gradient(-135deg, #fff 3px, transparent 0) 0 3px;
            background-size: 6px 6px; background-repeat: repeat-x;
        }
        .receipt::after {
            content: ""; position: absolute; bottom: -6px; left: 0; width: 100%; height: 6px;
            background: linear-gradient(45deg, #fff 3px, transparent 0) 0 3px,
                        linear-gradient(-45deg, #fff 3px, transparent 0) 0 3px;
            background-size: 6px 6px; background-repeat: repeat-x; transform: rotate(180deg);
        }

        h2 { text-align: center; margin: 0 0 5px 0; text-transform: uppercase; letter-spacing: 2px; font-size: 1.5rem; }
        .cabang { text-align: center; font-size: 0.8rem; margin-bottom: 20px; color: #555; }
        
        .meta { font-size: 0.8rem; border-bottom: 2px dashed #000; padding-bottom: 15px; margin-bottom: 15px; }
        .meta div { display: flex; justify-content: space-between; margin-bottom: 5px; }
        
        .item { display: flex; justify-content: space-between; font-size: 0.9rem; margin-bottom: 8px; }
        .item-name { font-weight: bold; }
        
        .total-section { 
            border-top: 2px dashed #000; margin-top: 15px; padding-top: 15px; 
            font-weight: bold; font-size: 1.2rem; display: flex; justify-content: space-between; 
        }
        
        .footer { text-align: center; margin-top: 30px; font-size: 0.7rem; color: #555; line-height: 1.5; }
        
        /* BUTTONS (Dihide pas Print) */
        .actions { margin-top: 25px; display: flex; gap: 10px; flex-direction: column; }
        
        .btn-print { 
            display: block; width: 100%; padding: 15px; 
            background: #000; color: #fff; text-align: center; border: none; 
            font-weight: bold; font-size: 1rem; cursor: pointer; border-radius: 8px;
        }
        .btn-home {
            display: block; width: 100%; padding: 15px; 
            background: #eee; color: #000; text-align: center; border: none; 
            font-weight: bold; font-size: 1rem; cursor: pointer; text-decoration: none; border-radius: 8px;
        }
        
        /* CLOSE BUTTON (X) */
        .close-absolute {
            position: absolute; top: 15px; right: 20px; 
            text-decoration: none; color: #000; font-size: 1.5rem; font-weight: bold; line-height: 1;
        }

    </style>
</head>
<body>

    <div class="receipt" id="area-cetak">
        
        <a href="./" class="close-absolute" data-html2canvas-ignore="true">&times;</a>

        <h2>MAKANCUY.</h2>
        <div class="cabang">Cabang: Jakarta Selatan</div>
        
        <div class="meta">
            <div><span>NO. ORDER</span> <span>#${orderId}</span></div>
            <div><span>PELANGGAN</span> <span>${sessionScope.user.username}</span></div>
            <div><span>TANGGAL</span> <span>${orderDate}</span></div>
            <div><span>METODE</span> <span>${paymentMethod}</span></div>
        </div>

        <c:forEach items="${orderItems}" var="item">
            <div class="item">
                <span class="item-name">${item.quantity}x ${item.menu.name}</span>
                <span>
                    <fmt:setLocale value="id_ID"/>
                    <fmt:formatNumber value="${item.menu.price * item.quantity}" maxFractionDigits="0"/>
                </span>
            </div>
        </c:forEach>

        <div class="total-section">
            <span>TOTAL</span>
            <span>
                Rp <fmt:formatNumber value="${orderTotal}" maxFractionDigits="0"/>
            </span>
        </div>

        <div class="footer">
            TERIMA KASIH SUDAH JAJAN.<br>
            PERUT KENYANG, HATI SENANG.<br>
            SIMPAN STRUK INI SEBAGAI BUKTI.
        </div>

        <div class="actions" data-html2canvas-ignore="true">
            <button onclick="downloadPDF()" class="btn-print">
                ⬇️ SIMPAN PDF (CETAK)
            </button>
            <a href="./" class="btn-home">
                🏠 BALIK KE MENU
            </a>
        </div>
    </div>

    <script>
        function downloadPDF() {
            // Ambil elemen struk
            var element = document.getElementById('area-cetak');
            
            // Settingan PDF yang Pas buat Struk
            var opt = {
                margin:       [0, 0, 0, 0], 
                filename:     'Struk_MakanCuy_#${orderId}.pdf',
                image:        { type: 'jpeg', quality: 0.98 },
                html2canvas:  { scale: 2, scrollY: 0 }, // Scale 2 biar tajem di HP
                jsPDF:        { unit: 'in', format: [3.5, 6], orientation: 'portrait' } 
                // Format [3.5, 6] inci itu mirip ukuran kertas struk panjang, bukan A4.
                // Jadi hasilnya di HP bakal full screen struk, gak ada kertas putih sisa banyak.
            };

            // Generate
            html2pdf().set(opt).from(element).save();
        }
    </script>

</body>
</html>