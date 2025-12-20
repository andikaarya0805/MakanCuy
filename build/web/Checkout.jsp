<%-- 
    Document   : Checkout
    Created on : Dec 20, 2025, 3:17:30 PM
    Author     : andik
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Checkout | MakanCuy</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    <style>
        body { background: #0d0d0d; color: #fff; font-family: 'Space Grotesk', sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .box { background: #1a1a1a; padding: 40px; border-radius: 20px; width: 100%; max-width: 500px; border: 1px solid #333; }
        h1 { margin-bottom: 20px; color: #ccff00; }
        .summary-item { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #333; }
        .total { font-size: 1.5rem; font-weight: bold; margin-top: 20px; text-align: right; color: #ccff00; }
        
        /* Style Pilihan Pembayaran */
        .payment-option { margin-top: 20px; }
        select { width: 100%; padding: 12px; background: #333; color: #fff; border: 1px solid #555; border-radius: 8px; font-size: 1rem; cursor: pointer; }
        .payment-info { background: #222; padding: 15px; border-radius: 8px; margin-top: 10px; border: 1px dashed #555; display: none; }
        
        .btn-pay { background: #ccff00; color: #000; width: 100%; padding: 15px; border: none; font-weight: bold; font-size: 1.2rem; margin-top: 30px; cursor: pointer; border-radius: 50px; }
        .btn-pay:hover { transform: scale(1.02); box-shadow: 0 0 20px rgba(204,255,0,0.5); }
    </style>
</head>
<body>
    <div class="box">
        <h1>Konfirmasi Order 🧾</h1>
        
        <div id="nota">Loading...</div>
        <div class="total" id="grandTotal">Rp 0</div>

        <form action="processOrder" method="POST">
            
            <div class="payment-option">
                <label style="font-weight: bold; color: #aaa;">Metode Pembayaran:</label>
                <select name="paymentMethod" id="paymentMethod" onchange="showPaymentInfo()">
                    <option value="COD">🏠 COD (cash or duel)</option>
                    <option value="QRIS">📱 QRIS (Scan Dulu)</option>
                    <option value="BANK">🏦 Transfer Bank</option>
                </select>

                <div id="info-QRIS" class="payment-info" style="text-align: center;">
                    <p>Scan QRIS di bawah ini:</p>
                    <img src="https://upload.wikimedia.org/wikipedia/commons/d/d0/QR_code_for_mobile_English_Wikipedia.svg" width="150" style="background: #fff; padding: 5px; border-radius: 5px;">
                    <p style="font-size: 0.8rem; color: #ccff00; margin-top: 5px;">*Ini QRIS Simulasi doang</p>
                </div>

                <div id="info-BANK" class="payment-info">
                    <p>Silakan transfer ke:</p>
                    <h3 style="color: #ccff00;">BCA: 4740942277</h3>
                    <p>A.n Andika Arya Pratama</p>
                </div>
            </div>

            <button type="submit" class="btn-pay">BAYAR SEKARANG</button>
        </form>
        
        <br>
        <div style="text-align: center;">
             <a href="./" style="color: #888; text-decoration: none;">&larr; Batal</a>
        </div>
    </div>

    <script>
        const rupiah = (number) => new Intl.NumberFormat("id-ID", {style: "currency", currency: "IDR", minimumFractionDigits: 0}).format(number);

        // Load Cart Data
        fetch('cart?action=view&mode=json')
            .then(res => res.json())
            .then(data => {
                let html = '';
                if(data.items.length === 0) {
                    document.querySelector('.box').innerHTML = "<h2>Keranjang Kosong!</h2><a href='./' style='color:#ccff00'>Belanja Dulu</a>";
                    return;
                }
                data.items.forEach(item => {
                    html += `
                        <div class="summary-item">
                            <span>`+item.quantity+`x `+item.menu.name+`</span>
                            <span>`+rupiah(item.menu.price * item.quantity)+`</span>
                        </div>`;
                });
                document.getElementById('nota').innerHTML = html;
                document.getElementById('grandTotal').innerText = rupiah(data.total);
            });

        // Logic Ganti Info Pembayaran
        function showPaymentInfo() {
            // Sembunyikan semua info dulu
            document.getElementById('info-QRIS').style.display = 'none';
            document.getElementById('info-BANK').style.display = 'none';
            
            // Ambil value yg dipilih
            const val = document.getElementById('paymentMethod').value;
            
            // Munculkan info yg sesuai
            if(val === 'QRIS') document.getElementById('info-QRIS').style.display = 'block';
            if(val === 'BANK') document.getElementById('info-BANK').style.display = 'block';
        }
    </script>
</body>
</html>