<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Invoice #${orderId}</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    
    <link href="https://fonts.googleapis.com/css2?family=Space+Mono&display=swap" rel="stylesheet">
    <style>
        body { background: #222; display: flex; justify-content: center; padding: 50px; font-family: 'Space Mono', monospace; }
        
        .receipt {
            background: #fff; width: 350px; padding: 20px; color: #000;
            box-shadow: 0 0 20px rgba(0,0,0,0.5); position: relative;
        }
        
        /* CSS Gerigi Kertas (Biar tetep estetik di PDF) */
        .receipt::before {
            content: ""; position: absolute; top: -10px; left: 0; width: 100%; height: 10px;
            background: linear-gradient(135deg, #fff 5px, transparent 0) 0 5px,
                        linear-gradient(-135deg, #fff 5px, transparent 0) 0 5px;
            background-size: 20px 10px; background-repeat: repeat-x;
        }
        .receipt::after {
            content: ""; position: absolute; bottom: -10px; left: 0; width: 100%; height: 10px;
            background: linear-gradient(45deg, #fff 5px, transparent 0) 0 5px,
                        linear-gradient(-45deg, #fff 5px, transparent 0) 0 5px;
            background-size: 20px 10px; background-repeat: repeat-x; transform: rotate(180deg);
        }

        h2 { text-align: center; margin: 0; text-transform: uppercase; letter-spacing: 2px; }
        .meta { font-size: 0.8rem; border-bottom: 2px dashed #000; padding: 10px 0; margin-bottom: 15px; }
        .item { display: flex; justify-content: space-between; font-size: 0.9rem; margin-bottom: 5px; }
        .total-section { border-top: 2px dashed #000; margin-top: 15px; padding-top: 10px; font-weight: bold; font-size: 1.1rem; display: flex; justify-content: space-between; }
        .footer { text-align: center; margin-top: 20px; font-size: 0.7rem; color: #555; }
        
        .close-btn { position: absolute; top: 15px; right: 20px; text-decoration: none; color: #000; font-size: 1.5rem; font-weight: bold; line-height: 1; }
        .btn-print { display: block; width: 100%; padding: 12px; background: #ccff00; color: #000; text-align: center; border: none; font-weight: bold; font-size: 0.9rem; cursor: pointer; margin-top: 20px; }
        
        /* Kelas buat ngumpetin elemen pas digenerate PDF */
        .hide-on-pdf { display: none !important; }
    </style>
</head>
<body>

    <div class="receipt" id="area-cetak">
        
        <a href="./" class="close-btn" data-html2canvas-ignore="true">&times;</a>

        <h2>MAKANCUY.</h2>
        <div style="text-align: center; font-size: 0.8rem;">Cabang : Jomokerto  </div>
        
        <div class="meta">
            <div>Order ID: #${orderId}</div>
            <div style="text-transform: uppercase; font-weight: bold;">Pelanggan: ${sessionScope.user.username}</div>
            <div>Tgl: ${orderDate}</div>
            <div>Bayar: ${paymentMethod}</div>
        </div>

        <c:forEach items="${orderItems}" var="item">
            <div class="item">
                <span>${item.quantity}x ${item.menu.name}</span>
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
            <p>TERIMA KASIH SUDAH JAJAN.<br>PERUT KENYANG, HATI SENANG.</p>
            <p>--- LUNAS (${paymentMethod}) ---</p>
        </div>

        <button onclick="downloadPDF()" class="btn-print" data-html2canvas-ignore="true">
            ⬇️ CETAK STRUK
        </button>
    </div>

    <script>
        function downloadPDF() {
            // Ambil elemen struk
            var element = document.getElementById('area-cetak');
            
            // Settingan PDF
            var opt = {
                margin:       [0, 0, 0, 0], // Margin atas, kiri, bawah, kanan
                filename:     'Invoice_MakanCuy_#${orderId}.pdf', // Nama file otomatis
                image:        { type: 'jpeg', quality: 0.98 },
                html2canvas:  { scale: 2 }, // Resolusi biar tajam
                jsPDF:        { unit: 'in', format: 'letter', orientation: 'portrait' }
            };

            // Generate dan Save
            html2pdf().set(opt).from(element).save();
        }
    </script>

</body>
</html>