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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout | MakanCuy</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    
    <style>
        /* --- TEMA GEN Z (SAMA KAYAK YG LAIN) --- */
        :root { --bg: #0d0d0d; --card: #1a1a1a; --accent: #ccff00; --text: #fff; --font: 'Space Grotesk', sans-serif; }
        
        body { 
            background: var(--bg); color: var(--text); font-family: var(--font); 
            display: flex; justify-content: center; align-items: center; 
            min-height: 100vh; margin: 0; 
            padding: 20px; /* Jarak aman bezel HP */
            box-sizing: border-box;
        }
        
        .box { 
            background: var(--card); padding: 40px; border-radius: 24px; width: 100%; max-width: 500px; 
            border: 1px solid #333; box-shadow: 0 0 30px rgba(0,0,0,0.5);
            position: relative;
        }
        
        h1 { margin-bottom: 20px; color: var(--accent); text-align: center; font-size: 2rem; }
        
        /* SUMMARY ITEMS */
        .summary-item { 
            display: flex; justify-content: space-between; padding: 12px 0; 
            border-bottom: 1px solid #333; font-size: 0.95rem; 
        }
        .summary-item span:first-child { color: #ccc; }
        .summary-item span:last-child { font-weight: bold; color: #fff; }
        
        .total { 
            font-size: 1.8rem; font-weight: bold; margin-top: 20px; 
            text-align: right; color: var(--accent); 
        }
        
        /* PAYMENT OPTIONS */
        .payment-option { margin-top: 25px; }
        .payment-label { font-weight: bold; color: #aaa; margin-bottom: 10px; display: block; }
        
        select { 
            width: 100%; padding: 15px; background: #000; color: #fff; 
            border: 1px solid #555; border-radius: 12px; font-size: 1rem; cursor: pointer; 
            font-family: var(--font); appearance: none;
            background-image: url("data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23ccff00%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E");
            background-repeat: no-repeat;
            background-position: right 15px top 50%;
            background-size: 12px auto;
        }
        
        .payment-info { 
            background: #222; padding: 20px; border-radius: 12px; margin-top: 15px; 
            border: 1px dashed #555; display: none; animation: fadeIn 0.3s;
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        
        /* BUTTON */
        .btn-pay { 
            background: var(--accent); color: #000; width: 100%; padding: 15px; border: none; 
            font-weight: bold; font-size: 1.2rem; margin-top: 30px; cursor: pointer; 
            border-radius: 50px; transition: 0.3s; 
        }
        .btn-pay:hover { transform: scale(1.02); box-shadow: 0 0 20px rgba(204,255,0,0.5); }
        
        /* LINKS */
        a { text-decoration: none; transition: 0.2s; }
        .back-link { color: #888; font-size: 0.9rem; }
        .back-link:hover { color: #fff; }

        /* --- MOBILE RESPONSIVE --- */
        @media (max-width: 480px) {
            .box { padding: 30px 20px; }
            h1 { font-size: 1.8rem; }
            .total { font-size: 1.5rem; }
        }
    </style>
</head>
<body>

    <div class="box">
        <h1>Konfirmasi Order 🧾</h1>
        
        <div id="nota">Loading...</div>
        <div class="total" id="grandTotal">Rp 0</div>

        <form action="processOrder" method="POST">
            
            <div class="payment-option">
                <label class="payment-label">Pilih Metode Pembayaran:</label>
                <select name="paymentMethod" id="paymentMethod" onchange="showPaymentInfo()">
                    <option value="COD">🏠 COD (Bayar di Tempat)</option>
                    <option value="QRIS">📱 QRIS (Scan Dulu)</option>
                    <option value="BANK">🏦 Transfer Bank</option>
                </select>

                <div id="info-QRIS" class="payment-info" style="text-align: center;">
                    <p style="margin-top: 0; color: #ccc;">Scan QRIS di bawah ini:</p>
                    <img src="https://upload.wikimedia.org/wikipedia/commons/d/d0/QR_code_for_mobile_English_Wikipedia.svg" width="180" style="background: #fff; padding: 10px; border-radius: 10px;">
                    <p style="font-size: 0.8rem; color: var(--accent); margin-top: 10px; margin-bottom: 0;">*Ini QRIS Simulasi doang</p>
                </div>

                <div id="info-BANK" class="payment-info" style="text-align: center;">
                    <p style="margin-top: 0; color: #ccc;">Silakan transfer ke:</p>
                    <h2 style="color: var(--accent); margin: 10px 0; letter-spacing: 1px;">BCA 4740942277</h2>
                    <p style="margin-bottom: 0; color: #888;">A.n Andika Arya Pratama</p>
                </div>
            </div>

            <button type="submit" class="btn-pay">BAYAR SEKARANG 🚀</button>
        </form>
        
        <div style="text-align: center; margin-top: 25px;">
             <a href="./" class="back-link">← Batal & Kembali Belanja</a>
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
                    document.querySelector('.box').innerHTML = "<h2 style='text-align:center;'>Keranjang Kosong! 🛒</h2><div style='text-align:center; margin-top:20px;'><a href='./' style='color:var(--accent); font-weight:bold; text-decoration:none;'>← Belanja Dulu Yuk</a></div>";
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
            })
            .catch(err => console.error("Gagal load cart:", err));

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