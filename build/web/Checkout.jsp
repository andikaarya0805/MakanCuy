<%-- 
    Document   : Checkout
    Created on : Dec 20, 2025
    Updated    : Jan 06, 2026 (Fix Price & Voucher)
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
        :root { --bg: #0d0d0d; --card: #1a1a1a; --accent: #ccff00; --text: #fff; --font: 'Space Grotesk', sans-serif; }
        body { background: var(--bg); color: var(--text); font-family: var(--font); display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; padding: 20px; box-sizing: border-box; }
        .box { background: var(--card); padding: 40px; border-radius: 24px; width: 100%; max-width: 500px; border: 1px solid #333; box-shadow: 0 0 30px rgba(0,0,0,0.5); }
        h1 { margin-bottom: 20px; color: var(--accent); text-align: center; font-size: 2rem; }
        .summary-item { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #333; font-size: 0.95rem; }
        .summary-item span:first-child { color: #ccc; }
        .summary-item span:last-child { font-weight: bold; color: #fff; }
        
        .discount-row { color: #ff4757 !important; display: none; } /* Hidden default */
        
        .total { font-size: 1.8rem; font-weight: bold; margin-top: 20px; text-align: right; color: var(--accent); }
        .payment-option { margin-top: 25px; }
        .payment-label { font-weight: bold; color: #aaa; margin-bottom: 10px; display: block; }
        select { width: 100%; padding: 15px; background: #000; color: #fff; border: 1px solid #555; border-radius: 12px; font-size: 1rem; cursor: pointer; font-family: var(--font); appearance: none; }
        .payment-info { background: #222; padding: 20px; border-radius: 12px; margin-top: 15px; border: 1px dashed #555; display: none; }
        .btn-pay { background: var(--accent); color: #000; width: 100%; padding: 15px; border: none; font-weight: bold; font-size: 1.2rem; margin-top: 30px; cursor: pointer; border-radius: 50px; transition: 0.3s; }
        .btn-pay:hover { transform: scale(1.02); box-shadow: 0 0 20px rgba(204,255,0,0.5); }
        a { text-decoration: none; transition: 0.2s; }
        .back-link { color: #888; font-size: 0.9rem; }
        .back-link:hover { color: #fff; }
    </style>
</head>
<body>

    <div class="box">
        <h1>Konfirmasi Order 🧾</h1>
        
        <div id="nota">Loading...</div>
        
        <div class="summary-item discount-row" id="nota-discount">
            <span>Diskon Voucher</span>
            <span id="discountVal">-Rp 0</span>
        </div>

        <div class="total" id="grandTotal">Rp 0</div>

        <form action="checkout-process" method="POST">
            <input type="hidden" name="voucherCode" id="hiddenVoucherCode" value="">

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
                </div>

                <div id="info-BANK" class="payment-info" style="text-align: center;">
                    <p style="margin-top: 0; color: #ccc;">Silakan transfer ke:</p>
                    <h2 style="color: var(--accent); margin: 10px 0;">BCA 4740942277</h2>
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

        // 1. Ambil Kode Voucher dari URL (yang dikirim index.jsp)
        const urlParams = new URLSearchParams(window.location.search);
        const voucherCode = urlParams.get('code') || '';
        
        // Simpan ke input hidden biar kebawa pas submit
        document.getElementById('hiddenVoucherCode').value = voucherCode;

        // 2. Load Cart Data & Hitung Ulang
        fetch('cart?action=view&mode=json')
            .then(res => res.json())
            .then(data => {
                let html = '';
                let subTotal = data.total;
                let finalTotal = subTotal;

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

                // 3. Cek Voucher Lagi (Biar Harga Sesuai)
                if(voucherCode) {
                    fetch('cart?action=check_voucher&code=' + voucherCode)
                        .then(r => r.json())
                        .then(v => {
                            if(v.discount > 0) {
                                let discountAmount = (subTotal * v.discount) / 100;
                                finalTotal = subTotal - discountAmount;
                                
                                // Tampilkan Diskon
                                document.getElementById('nota-discount').style.display = 'flex';
                                document.getElementById('discountVal').innerText = "- " + rupiah(discountAmount);
                            }
                            document.getElementById('grandTotal').innerText = rupiah(finalTotal);
                        });
                } else {
                    document.getElementById('grandTotal').innerText = rupiah(finalTotal);
                }
            })
            .catch(err => console.error("Gagal load cart:", err));

        function showPaymentInfo() {
            document.getElementById('info-QRIS').style.display = 'none';
            document.getElementById('info-BANK').style.display = 'none';
            const val = document.getElementById('paymentMethod').value;
            if(val === 'QRIS') document.getElementById('info-QRIS').style.display = 'block';
            if(val === 'BANK') document.getElementById('info-BANK').style.display = 'block';
        }
    </script>
</body>
</html>