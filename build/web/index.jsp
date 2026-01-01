<%-- 
    Document   : index
    Created on : Dec 20, 2025, 4:57:31?PM
    Author     : andik
--%><

%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="com.makancuy.dao.MenuDAO" %>
<%@ page import="com.makancuy.model.MenuItem" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.gson.Gson" %>

<%
    // --- 1. LOGIC JAVA UTAMA (JANGAN DIHAPUS) ---
    MenuDAO menuDAO = new MenuDAO();
    List<MenuItem> menuList = menuDAO.getAllMenus();

    // A. Handle Request JSON (Buat Auto-Update JavaScript)
    String mode = request.getParameter("mode");
    if ("json".equals(mode)) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(menuList));
        return; 
    }

    // B. Handle Request Biasa (Buat Tampilan HTML Awal)
    request.setAttribute("genZMenu", menuList);
%>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MakanCuy | Food for Gen Z</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    
    <style>
        /* --- GEN Z THEME VARIABLES --- */
    :root {
        --bg-color: #0d0d0d;
        --card-bg: #1a1a1a;
        --text-main: #ffffff;
        --text-sec: #a1a1a1;
        --accent-green: #ccff00;
        --font-main: 'Space Grotesk', sans-serif;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
        background-color: var(--bg-color);
        color: var(--text-main);
        font-family: var(--font-main);
        overflow-x: hidden;
    }

    /* UTILS */
    .container { max-width: 1200px; margin: 0 auto; padding: 0 20px; }
    
    .btn { padding: 12px 32px; border-radius: 50px; font-weight: 700; cursor: pointer; border: none; transition: 0.3s; text-decoration: none; display: inline-block; }
    .btn-primary { background-color: var(--accent-green); color: #000; }
    .btn-primary:hover { transform: scale(1.05) rotate(-2deg); box-shadow: 0 0 20px rgba(204, 255, 0, 0.4); }

    /* NAVBAR DEFAULT (DESKTOP) */
    nav { display: flex; justify-content: space-between; align-items: center; padding: 30px 0; }
    .logo { font-size: 1.8rem; font-weight: 700; letter-spacing: -1px; }
    .logo span { color: var(--accent-green); }
    .nav-links { display: flex; align-items: center; gap: 20px; }

    /* === HERO SECTION === */
    .hero { 
        display: flex; 
        align-items: center; 
        justify-content: space-between; 
        flex-direction: row; 
        min-height: 60vh; 
        margin-bottom: 50px; 
    }
    .hero h1 { font-size: 4rem; line-height: 1; margin-bottom: 20px; letter-spacing: -2px; }
    .hero h1 span { -webkit-text-stroke: 1px var(--accent-green); color: transparent; }
    .hero p { color: var(--text-sec); margin-bottom: 30px; max-width: 500px; } 
    
    .hero-img img { 
        width: 350px; height: 350px; object-fit: cover; border-radius: 50%; 
        border: 2px solid var(--accent-green); animation: float 6s ease-in-out infinite; 
    }

    /* === MENU GRID === */
    .food-grid { 
        display: grid; 
        grid-template-columns: repeat(4, 1fr); 
        gap: 20px; 
        margin-bottom: 100px; 
    }
    
    .food-card {
        background: var(--card-bg); border-radius: 24px; padding: 15px;
        border: 1px solid #333; transition: 0.3s; position: relative;
        height: 100%; display: flex; flex-direction: column; justify-content: space-between;
    }
    .food-card:hover { transform: translateY(-5px); border-color: var(--accent-green); }
    
    .food-img { width: 100%; height: 180px; object-fit: cover; border-radius: 16px; margin-bottom: 15px; }
    
    .category-tag {
        position: absolute; top: 10px; right: 10px;
        background: rgba(0,0,0,0.7); color: #fff;
        padding: 4px 10px; border-radius: 20px; font-size: 0.7rem;
    }
    .price { color: var(--accent-green); font-weight: 700; font-size: 1.1rem; }
    
    /* FILTER BUTTONS */
    .filter-container {
        display: flex; gap: 10px; margin-bottom: 30px; 
        overflow-x: auto; padding-bottom: 10px;
        -webkit-overflow-scrolling: touch;
    }
    .filter-container::-webkit-scrollbar { height: 4px; }
    .filter-container::-webkit-scrollbar-thumb { background: #333; border-radius: 10px; }
    .filter-btn {
        background: var(--card-bg); border: 1px solid #333; color: var(--text-sec);
        padding: 8px 20px; border-radius: 50px; cursor: pointer; transition: 0.3s;
        font-family: var(--font-main); font-weight: 500; white-space: nowrap; font-size: 0.9rem;
    }
    .filter-btn:hover, .filter-btn.active {
        background: var(--accent-green); color: #000; border-color: var(--accent-green);
    }

    /* CART SIDEBAR */
    .cart-btn { position: fixed; bottom: 30px; right: 30px; background: var(--accent-green); color: #000; width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; cursor: pointer; z-index: 1000; box-shadow: 0 0 20px rgba(204, 255, 0, 0.5); }
    .cart-sidebar { position: fixed; top: 0; right: -400px; width: 320px; max-width: 90%; height: 100vh; background: #111; border-left: 1px solid #333; padding: 20px; z-index: 1001; transition: 0.4s; display: flex; flex-direction: column; }
    .cart-sidebar.active { right: 0; }
    .cart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #333; padding-bottom: 10px; }
    .cart-items { flex: 1; overflow-y: auto; }
    .cart-item { display: flex; gap: 10px; margin-bottom: 15px; background: #222; padding: 10px; border-radius: 10px; }
    .cart-item img { width: 50px; height: 50px; border-radius: 5px; object-fit: cover; }
    .cart-total { font-size: 1.5rem; font-weight: bold; color: var(--accent-green); margin: 20px 0; }
    .overlay { position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.7); z-index:900; display:none; }
    .overlay.active { display:block; }
    .qty-btn { background: #333; color: #fff; width: 25px; height: 25px; border-radius: 5px; border: none; cursor: pointer; font-weight: bold; display: inline-flex; align-items: center; justify-content: center; transition: 0.2s; }
    .qty-btn:hover { background: var(--accent-green); color: #000; }
    
    @keyframes float { 0%, 100% { transform: translateY(0px); } 50% { transform: translateY(-20px); } }

    /* === ANDROID STYLE TOAST NOTIFICATION (NEW) === */
    .toast-container { position: fixed; top: 20px; left: 50%; transform: translateX(-50%); z-index: 9999; width: 90%; max-width: 380px; }
    .toast {
        background: rgba(20, 20, 20, 0.95);
        backdrop-filter: blur(10px);
        border: 1px solid #333;
        border-left: 4px solid var(--accent-green);
        color: #fff;
        padding: 15px;
        border-radius: 16px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        display: flex;
        align-items: center;
        gap: 15px;
        animation: slideDown 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        opacity: 1;
        transition: opacity 0.5s ease;
        margin-bottom: 10px;
    }
    .toast-icon { font-size: 1.5rem; }
    .toast-content h4 { margin: 0; font-size: 0.95rem; color: var(--accent-green); margin-bottom: 3px; font-weight: 700; }
    .toast-content p { margin: 0; font-size: 0.85rem; color: #ccc; line-height: 1.3; }
    
    @keyframes slideDown { from { transform: translateY(-50px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

    /* === MOBILE RESPONSIVE === */
    @media (max-width: 768px) {
        nav { flex-direction: column; gap: 20px; text-align: center; }
        .nav-links { flex-direction: column; gap: 15px; }
        .hero { flex-direction: column-reverse; text-align: center; justify-content: center; gap: 30px; margin-top: 20px; }
        .hero h1 { font-size: 2.5rem; }
        .hero-img img { width: 220px; height: 220px; margin: 0 auto; }
        .food-grid { grid-template-columns: repeat(2, 1fr); gap: 15px; }
        .food-img { height: 140px; }
    }
    </style>
</head>
<body>

    <div id="toastContainer" class="toast-container"></div>

    <div class="container">
        
        <nav>
            <div class="logo">Makan<span>Cuy</span>.</div>
            
            <div class="nav-links">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <div style="display: flex; gap: 20px; align-items: center; flex-wrap: wrap; justify-content: center;">
                            <span style="color: var(--accent-green); font-weight: bold; font-size: 1.1rem;">
                                Halo, ${sessionScope.user.username} ?
                            </span>

                            <a href="history" style="color: #fff; text-decoration: none; font-size: 0.9rem; transition:0.3s;" onmouseover="this.style.color='#ccff00'" onmouseout="this.style.color='#fff'">
                                ? Riwayat
                            </a>

                            <c:if test="${sessionScope.user.role == 'admin'}">
                                <a href="admin" style="color: #fff; text-decoration: none; font-size: 0.9rem; border-bottom: 1px solid #fff;">Dashboard</a>
                            </c:if>

                            <a href="auth" style="color: var(--text-sec); text-decoration: none; border: 1px solid #333; padding: 8px 20px; border-radius: 50px; font-size: 0.9rem; transition:0.3s;" onmouseover="this.style.borderColor='red';this.style.color='red'" onmouseout="this.style.borderColor='#333';this.style.color='#a1a1a1'">
                                Logout
                            </a>
                        </div>
                    </c:when>
                    
                    <c:otherwise>
                        <a href="login.jsp" class="btn-primary" style="padding: 10px 25px; text-decoration: none; border-radius: 50px; font-size: 0.9rem;">
                            Login Akun
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </nav>

        <section class="hero">
            <div>
                <h1>PERUT<br><span>KOSONG?</span><br>GASLAH.</h1>
                <p style="color: var(--text-sec); margin-bottom: 30px;">Makanan enak, harga mahasiswa, vibes asik.</p>
                <a href="#menu" class="btn btn-primary">Lihat Menu ?</a>
            </div>
            <div class="hero-img">
                <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600" alt="Burger">
            </div>
        </section>

        <h2 id="menu" style="font-size: 2.5rem; margin-bottom: 30px;">Menu Hype ?</h2>
        
        <div class="filter-container">
            <button class="filter-btn active" onclick="setCategory('all', this)">Semua</button>
            <button class="filter-btn" onclick="setCategory('Makanan', this)">Makanan</button>
            <button class="filter-btn" onclick="setCategory('Minuman', this)">Minuman</button>
            <button class="filter-btn" onclick="setCategory('Cemilan', this)">Cemilan</button>
        </div>

        <div class="food-grid">
            <c:forEach items="${genZMenu}" var="item">
                <div class="food-card">
                    <span class="category-tag">${item.category}</span>
                    <c:set var="gambar" value="${item.imageUrl}" />
                    <c:if test="${empty gambar}">
                        <c:set var="gambar" value="https://dummyimage.com/300x200/333/fff&text=No+Image" />
                    </c:if>

                    <img src="${gambar}" class="food-img" alt="${item.name}">
                    
                    <div class="food-info">
                        <h3 style="margin-bottom: 5px; color: #fff;">${item.name}</h3>
                        <p style="color: var(--text-sec); font-size: 0.9rem; margin-bottom: 20px;">
                            ${item.description}
                        </p>
                    </div>
                    
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span class="price">
                            <fmt:setLocale value="id_ID"/>
                            <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="Rp " maxFractionDigits="0"/>
                        </span>
                        
                        <a href="cart?action=add&id=${item.id}" 
                           style="background: #fff; color: #000; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight:bold; cursor: pointer; text-decoration: none; transition: 0.2s;">
                           +
                        </a>
                    </div>
                </div>
            </c:forEach>
        </div>

        <footer style="text-align: center; padding-bottom: 50px; color: var(--text-sec); font-size: 0.8rem; margin-top: 50px;">
            &copy; 2025 MakanCuy Project. All Rights Reserved.
        </footer>
    </div>

    <div class="cart-btn" onclick="toggleCart()">?</div>
    <div class="overlay" onclick="toggleCart()"></div>

    <div class="cart-sidebar">
        <div class="cart-header">
            <h2>Keranjang</h2>
            <span style="cursor:pointer; font-size:1.5rem;" onclick="toggleCart()">×</span>
        </div>
        
        <div class="cart-items" id="cartList">
            <p style="text-align:center; color:#555; margin-top:50px;">Masih kosong nih.</p>
        </div>

        <div>
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <span>Total:</span>
                <span class="cart-total" id="cartTotal">Rp 0</span>
            </div>
            <a href="Checkout.jsp" class="btn btn-primary" style="width:100%; text-align:center;">CHECKOUT ?</a>
        </div>
    </div>

<script>
    const rupiah = (number) => new Intl.NumberFormat("id-ID", {style: "currency", currency: "IDR", minimumFractionDigits: 0}).format(number);

    // ==========================================
    // ? 1. SYSTEM NOTIFIKASI REAL-TIME (BARU)
    // ==========================================
    
    // Simpan status terakhir di browser biar gak spam notif
    let lastStatus = localStorage.getItem('lastStatus') || "";
    let lastOrderId = localStorage.getItem('lastOrderId') || 0;

        function checkOrderStatus() {
        // [UPDATE] Tambahin timestamp (?t=...) biar browser gak nge-cache data lama
        const timestamp = new Date().getTime(); 
        
        fetch('api/user-status?t=' + timestamp) // <--- UBAH BARIS INI
            .then(res => res.json())
            .then(data => {
                if (!data.status) return; // Kalau gak ada order aktif, skip

                // Cek apakah ada perubahan status atau ID order baru
                if (data.status !== lastStatus || data.orderId != lastOrderId) {
                    
                    if (data.status === 'PROCESSING') {
                        showToast("??? Pesanan Dimasak", "Koki lagi beraksi, tunggu bentar ya!");
                    } else if (data.status === 'DELIVERING') {
                        showToast("? Pesanan Diantar", "Makananmu lagi OTW ke meja!");
                    } else if (data.status === 'COMPLETED') {
                        showToast("? Pesanan Selesai", "Selamat menikmati makanannya! ?");
                    } else if (data.status === 'REJECTED') {
                        showToast("? Pesanan Dibatalkan", "Maaf, pesananmu ditolak admin.");
                    }

                    // Update simpanan lokal
                    lastStatus = data.status;
                    lastOrderId = data.orderId;
                    localStorage.setItem('lastStatus', lastStatus);
                    localStorage.setItem('lastOrderId', lastOrderId);
                }
            })
            .catch(err => {
                // Silent error (biar gak nuhin console)
            });
    }

    function showToast(title, msg) {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = 'toast';
        
        // Ikon sesuai judul
        let icon = '?';
        if(title.includes('Dimasak')) icon = '?';
        if(title.includes('Diantar')) icon = '?';
        if(title.includes('Selesai')) icon = '?';
        if(title.includes('Dibatalkan')) icon = '?';

        toast.innerHTML = `
            <div class="toast-icon">` + icon + `</div>
            <div class="toast-content">
                <h4>` + title + `</h4>
                <p>` + msg + `</p>
            </div>
        `;

        container.appendChild(toast);

        // Notif hilang otomatis dalam 9 detik
        setTimeout(() => {
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 500);
        }, 9000);
    }

    // Jalankan cek status tiap 1 detik
    setInterval(checkOrderStatus, 1000);


    // ==========================================
    // 2. LOGIC MENU & CART (LAMA)
    // ==========================================
    
    let currentCategory = 'all'; 

    function setCategory(cat, btn) {
        currentCategory = cat;
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        loadMenu(); 
    }

    function loadMenu() {
        fetch('?mode=json')
            .then(response => {
                if (!response.ok) throw new Error("Gagal fetch data");
                return response.json();
            })
            .then(data => {
                let html = '';
                const container = document.querySelector('.food-grid');
                
                let filteredData = data;
                if (currentCategory !== 'all') {
                    filteredData = data.filter(item => item.category === currentCategory);
                }

                if (filteredData.length === 0) {
                    container.innerHTML = '<div class="food-card" style="grid-column: 1/-1; text-align:center; padding:40px;"><h3>Yah, kategori ini kosong! ?</h3></div>';
                    return;
                }

                filteredData.forEach(item => {
                    let img = (item.imageUrl && item.imageUrl.length > 5) ? item.imageUrl : 'https://dummyimage.com/300x200/333/fff&text=No+Image';
                    
                    html += `
                        <div class="food-card">
                            <span class="category-tag">` + item.category + `</span>
                            <img src="` + img + `" class="food-img" alt="` + item.name + `">
                            
                            <div class="food-info">
                                <h3 style="margin-bottom: 5px; color: #fff;">` + item.name + `</h3>
                                <p style="color: var(--text-sec); font-size: 0.9rem; margin-bottom: 20px;">
                                    ` + item.description + `
                                </p>
                            </div>
                            
                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <span class="price">` + rupiah(item.price) + `</span>

                                <a href="cart?action=add&id=` + item.id + `" 
                                   style="background: #fff; color: #000; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight:bold; cursor: pointer; text-decoration: none; transition: 0.2s;">
                                   +
                                </a>
                            </div>
                        </div>
                    `;
                });
                
                container.innerHTML = html;
            })
            .catch(err => console.error('Error Auto Update:', err));
    }

    // Auto Update Menu (Biar kalau admin ubah harga, user langsung liat)
    setInterval(loadMenu, 1000);

    function updateCartItem(menuId, change) {
        fetch('cart?action=update&id=' + menuId + '&qty=' + change)
            .then(res => { loadCart(); })
            .catch(err => console.error("Gagal update:", err));
    }

    function toggleCart() {
        const sidebar = document.querySelector('.cart-sidebar');
        const overlay = document.querySelector('.overlay');
        sidebar.classList.toggle('active');
        overlay.classList.toggle('active');
        
        if (sidebar.classList.contains('active')) {
            loadCart();
        }
    }

    function loadCart() {
        fetch('cart?action=view&mode=json')
            .then(res => {
                if (res.status === 401) {
                    window.location.href = "login.jsp"; 
                    return;
                }
                return res.json();
            })
            .then(data => {
                const list = document.getElementById('cartList');
                const total = document.getElementById('cartTotal');
                
                if (data.items.length === 0) {
                    list.innerHTML = '<p style="text-align:center; color:#555; margin-top:50px;">Masih kosong nih.</p>';
                    total.innerText = rupiah(0);
                    return;
                }

                let html = '';
                data.items.forEach(item => {
                    let img = item.menu.imageUrl || 'https://dummyimage.com/50x50/333/fff';
                    html += `
                        <div class="cart-item">
                            <img src="`+img+`">
                            <div style="flex:1;">
                                <div style="font-weight:bold; font-size:0.9rem;">`+item.menu.name+`</div>
                                <div style="font-size:0.8rem; color:#888; margin-top:5px; display:flex; align-items:center; gap:8px;">
                                    <button class="qty-btn" onclick="updateCartItem(`+item.menu.id+`, -1)">-</button>
                                    <span>`+item.quantity+`</span>
                                    <button class="qty-btn" onclick="updateCartItem(`+item.menu.id+`, 1)">+</button>
                                </div>
                            </div>
                            <div style="font-weight:bold; color:var(--accent-green);">
                                `+rupiah(item.menu.price * item.quantity)+`
                            </div>
                        </div>
                    `;
                });
                
                list.innerHTML = html;
                total.innerText = rupiah(data.total);
            })
            .catch(err => console.error("Gagal load cart:", err));
    }
</script>
</body>
</html>