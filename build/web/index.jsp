<%-- 
    Document   : index
    Created on : Dec 20, 2025, 4:57:31?PM
    Author     : andik
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="com.makancuy.dao.MenuDAO" %>
<%@ page import="com.makancuy.model.MenuItem" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.gson.Gson" %>

<%
    // --- LOGIC JAVA UTAMA ---
    MenuDAO menuDAO = new MenuDAO();
    List<MenuItem> menuList = menuDAO.getAllMenus();

    String mode = request.getParameter("mode");
    if ("json".equals(mode)) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(menuList));
        return; 
    }

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
        :root { --bg-color: #0d0d0d; --card-bg: #1a1a1a; --text-main: #ffffff; --text-sec: #a1a1a1; --accent-green: #ccff00; --font-main: 'Space Grotesk', sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background-color: var(--bg-color); color: var(--text-main); font-family: var(--font-main); overflow-x: hidden; }

        /* UTILS */
        .container { max-width: 1200px; margin: 0 auto; padding: 0 20px; }
        .btn { padding: 12px 32px; border-radius: 50px; font-weight: 700; cursor: pointer; border: none; transition: 0.3s; text-decoration: none; display: inline-block; }
        .btn-primary { background-color: var(--accent-green); color: #000; }
        .btn-primary:hover { transform: scale(1.05); box-shadow: 0 0 20px rgba(204, 255, 0, 0.4); }

        /* NAVBAR (ADAPTIVE) */
        nav { display: flex; justify-content: space-between; align-items: center; padding: 25px 0; position: relative; z-index: 1000; }
        .logo { font-size: 1.8rem; font-weight: 700; letter-spacing: -1px; }
        .logo span { color: var(--accent-green); }
        .nav-group { display: flex; align-items: center; gap: 20px; }
        .nav-links { display: flex; gap: 20px; align-items: center; list-style: none; }
        .nav-links a { color: var(--text-sec); text-decoration: none; font-weight: 500; transition: 0.3s; font-size: 0.95rem; }
        .nav-links a:hover { color: var(--accent-green); }
        .hamburger { display: none; font-size: 1.8rem; cursor: pointer; color: #fff; background: none; border: none; }

        .cart-btn { position: fixed; bottom: 30px; right: 30px; background: var(--accent-green); color: #000; width: 60px; height: 60px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; cursor: pointer; z-index: 1000; box-shadow: 0 0 20px rgba(204, 255, 0, 0.5); }

        /* HERO SECTION */
        .hero { display: flex; align-items: center; justify-content: space-between; min-height: 60vh; margin-bottom: 50px; }
        .hero h1 { font-size: 4rem; line-height: 1; margin-bottom: 20px; letter-spacing: -2px; }
        .hero h1 span { -webkit-text-stroke: 1px var(--accent-green); color: transparent; }
        .hero p { color: var(--text-sec); margin-bottom: 30px; max-width: 500px; } 
        .hero-img img { width: 350px; height: 350px; object-fit: cover; border-radius: 50%; border: 2px solid var(--accent-green); animation: float 6s ease-in-out infinite; }

        /* GRID MENU (OLD STYLE YG LU SUKA) */
        .food-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 100px; }
        .food-card { background: var(--card-bg); border-radius: 24px; padding: 15px; border: 1px solid #333; transition: 0.3s; position: relative; height: 100%; display: flex; flex-direction: column; justify-content: space-between; }
        .food-card:hover { transform: translateY(-5px); border-color: var(--accent-green); }
        .food-img { width: 100%; height: 180px; object-fit: cover; border-radius: 16px; margin-bottom: 15px; }
        .category-tag { position: absolute; top: 10px; right: 10px; background: rgba(0,0,0,0.7); color: #fff; padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; }
        .price { color: var(--accent-green); font-weight: 700; font-size: 1.1rem; }

        /* FILTER */
        .filter-container { display: flex; gap: 10px; margin-bottom: 30px; overflow-x: auto; padding-bottom: 10px; -webkit-overflow-scrolling: touch; }
        .filter-btn { background: var(--card-bg); border: 1px solid #333; color: var(--text-sec); padding: 8px 20px; border-radius: 50px; cursor: pointer; transition: 0.3s; font-family: var(--font-main); font-weight: 500; white-space: nowrap; font-size: 0.9rem; }
        .filter-btn:hover, .filter-btn.active { background: var(--accent-green); color: #000; border-color: var(--accent-green); }

        /* CART SIDEBAR */
        .cart-sidebar { position: fixed; top: 0; right: -400px; width: 350px; max-width: 85%; height: 100vh; background: #111; padding: 25px; z-index: 2000; transition: 0.4s; display: flex; flex-direction: column; border-left: 1px solid #333; }
        .cart-sidebar.active { right: 0; }
        .overlay { position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.8); backdrop-filter: blur(5px); z-index:1500; display:none; }
        .overlay.active { display:block; }
        
        .cart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #333; padding-bottom: 10px; }
        .cart-items { flex: 1; overflow-y: auto; }
        .cart-item { display: flex; gap: 10px; margin-bottom: 15px; background: #222; padding: 10px; border-radius: 10px; }
        .cart-item img { width: 50px; height: 50px; border-radius: 5px; object-fit: cover; }
        .qty-btn { background: #333; color: #fff; width: 25px; height: 25px; border-radius: 5px; border: none; cursor: pointer; font-weight: bold; display: inline-flex; align-items: center; justify-content: center; transition: 0.2s; }
        .qty-btn:hover { background: var(--accent-green); color: #000; }

        /* NOTIF POPUP */
        .toast-container { position: fixed; top: 20px; left: 50%; transform: translateX(-50%); z-index: 9999; width: 90%; max-width: 380px; }
        .toast { background: rgba(26, 26, 26, 0.95); backdrop-filter: blur(10px); border: 1px solid #333; border-left: 4px solid var(--accent-green); color: #fff; padding: 15px; border-radius: 16px; display: flex; align-items: center; gap: 15px; margin-bottom: 10px; animation: slideDown 0.5s; }
        
        /* MARQUEE (DESKTOP ONLY) */
        .marquee-container { background: var(--accent-green); color: #000; padding: 15px 0; transform: rotate(-2deg); width: 105%; margin-left: -10px; margin-bottom: 50px; overflow: hidden; white-space: nowrap; }
        .marquee-content { display: inline-block; font-weight: 900; font-size: 1.5rem; text-transform: uppercase; animation: scroll 20s linear infinite; }

        @keyframes slideDown { from { transform: translateY(-50px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        @keyframes float { 0%, 100% { transform: translateY(0px); } 50% { transform: translateY(-20px); } }
        @keyframes scroll { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }

        /* MOBILE RESPONSIVE */
        @media (max-width: 768px) {
            /* 1. HIDE MARQUEE DI HP */
            .marquee-container { display: none; }

            /* 2. MENU ADAPTIVE */
            .hero { flex-direction: column-reverse; text-align: center; justify-content: center; gap: 30px; margin-top: 20px; }
            .hero h1 { font-size: 2.5rem; }
            .hero-img img { width: 220px; height: 220px; margin: 0 auto; }
            
            /* 3. GRID 2 KOLOM (Mobile) */
            .food-grid { grid-template-columns: repeat(2, 1fr); gap: 15px; }
            .food-img { height: 140px; }
            
            /* 4. HAMBURGER NAV */
            .hamburger { display: block; }
            .nav-links { position: absolute; top: 80px; left: 0; right: 0; background: #111; flex-direction: column; padding: 20px; border-bottom: 1px solid #333; display: none; }
            .nav-links.active { display: flex; }
        }
    </style>
</head>
<body>

    <div id="toastContainer" class="toast-container"></div>

    <div class="container">
        <nav>
            <div class="logo">Makan<span>Cuy</span>.</div>
            <div class="nav-group">
                <div class="nav-links" id="navLinks">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <span style="color: var(--accent-green); font-weight: bold;">
                                ${sessionScope.user.username} 👋
                            </span>
                            <a href="history">📦 Status Order</a>
                            <a href="history">📜 Riwayat</a>
                            <c:if test="${sessionScope.user.role == 'admin'}">
                                <a href="admin">Dashboard</a>
                            </c:if>
                            <a href="auth" style="color: #ff4757;">Logout</a>
                        </c:when>
                        <c:otherwise>
                            <a href="login.jsp" class="btn btn-primary" style="padding: 8px 24px; font-size: 0.9rem; color: #111">Login Akun</a>
                        </c:otherwise>
                    </c:choose>
                </div>
                <button class="hamburger" onclick="toggleMenu()">☰</button>
            </div>
        </nav>

        <section class="hero">
            <div>
                <h1>PERUT<br><span>KOSONG?</span><br>GASLAH.</h1>
                <p style="color: var(--text-sec); margin-bottom: 30px; max-width: 500px; line-height: 1.6;">
        Skip drama <i>'terserah mau makan apa'</i>. Di sini menunya enak semua, <b>no debat</b>. 
        Lo tinggal klik, bayar, perut aman, idup tentram. ✨
    </p>
                <a href="#menu" class="btn btn-primary">Lihat Menu ➜</a>
            </div>
            <div class="hero-img">
                <img src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600" alt="Burger">
            </div>
        </section>

        <div class="marquee-container">
            <div class="marquee-content">
                • JANGAN BIARKAN LAPAR MENGGANGGU SKRIPSI • DISKON 50% UNTUK SOBAT AMBYAR • Intisari • Kawa kawa • AYAM GEPREK • ES KOPI SUSU GULA AREN •
                • JANGAN BIARKAN LAPAR MENGGANGGU SKRIPSI • DISKON 50% UNTUK SOBAT AMBYAR • Intisari • Kawa kawa • AYAM GEPREK • ES KOPI SUSU GULA AREN •
            </div>
        </div>

        <h2 id="menu" style="font-size: 2.5rem; margin-bottom: 30px;">Menu Hype 🔥</h2>
        
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
                    <c:if test="${empty gambar}"><c:set var="gambar" value="https://dummyimage.com/300x200/333/fff&text=No+Image" /></c:if>
                    <img src="${gambar}" class="food-img" alt="${item.name}">
                    <div class="food-info">
                        <h3 style="margin-bottom: 5px; color: #fff;">${item.name}</h3>
                        <p style="color: var(--text-sec); font-size: 0.9rem; margin-bottom: 20px;">${item.description}</p>
                    </div>
                    <div style="display: flex; justify-content: space-between; align-items: center;">
                        <span class="price"><fmt:setLocale value="id_ID"/><fmt:formatNumber value="${item.price}" type="currency" currencySymbol="Rp " maxFractionDigits="0"/></span>
                        <a href="cart?action=add&id=${item.id}" style="background: #fff; color: #000; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight:bold; cursor: pointer; text-decoration: none; transition: 0.2s;">+</a>
                    </div>
                </div>
            </c:forEach>
        </div>

        <footer style="text-align: center; padding-bottom: 50px; color: var(--text-sec); font-size: 0.8rem; margin-top: 50px;">
            &copy; 2025 Dika Project. All Rights Reserved.
        </footer>
    </div>

    <div class="cart-btn" onclick="toggleCart()">🛒</div>
    <div class="overlay" onclick="toggleCart()"></div>

    <div class="cart-sidebar">
        <div class="cart-header">
            <h2>Keranjang</h2>
            <span style="cursor:pointer; font-size:1.5rem;" onclick="toggleCart()">×</span>
        </div>
        <div class="cart-items" id="cartList"><p style="text-align:center; color:#555; margin-top:50px;">Masih kosong nih.</p></div>
        <div>
            <div style="display:flex; justify-content:space-between; align-items:center;">
                <span>Total:</span><span id="cartTotal" style="font-size:1.5rem; font-weight:bold; color:var(--accent-green);">Rp 0</span>
            </div>
            <a href="Checkout.jsp" class="btn btn-primary" style="width:100%; text-align:center;">CHECKOUT ➔</a>
        </div>
    </div>

<script>
    // --- UTILS & HAMBURGER ---
    function toggleMenu() { document.getElementById('navLinks').classList.toggle('active'); }
    const rupiah = (n) => new Intl.NumberFormat("id-ID", {style: "currency", currency: "IDR", minimumFractionDigits: 0}).format(n);

    // --- NOTIFIKASI SYSTEM ---
    let lastStatus = localStorage.getItem('lastStatus') || "";
    let lastOrderId = localStorage.getItem('lastOrderId') || 0;
    function checkOrderStatus() {
        const timeParams = new Date().getTime(); 
        fetch('api/user-status?nocache=' + timeParams).then(r=>r.json()).then(data => {
            if (!data.status) return;
            if (data.status !== lastStatus || data.orderId != lastOrderId) {
                let title = "Update Pesanan", msg = "Status berubah.";
                if (data.status === 'PROCESSING') { title = "🔥 Pesanan Dimasak"; msg = "Mohon tunggu sebentar!"; } 
                else if (data.status === 'DELIVERING') { title = "🛵 Pesanan Diantar"; msg = "Makanan OTW ke meja!"; } 
                else if (data.status === 'COMPLETED') { title = "✅ Selesai"; msg = "Selamat makan! 😋"; } 
                else if (data.status === 'REJECTED') { title = "❌ Dibatalkan"; msg = "Maaf, pesanan ditolak."; }
                showToast(title, msg);
                lastStatus = data.status; lastOrderId = data.orderId;
                localStorage.setItem('lastStatus', lastStatus); localStorage.setItem('lastOrderId', lastOrderId);
            }
        }).catch(e=>{});
    }
    function showToast(title, msg) {
        const container = document.getElementById('toastContainer');
        const t = document.createElement('div'); t.className = 'toast';
        t.innerHTML = `<div>🔔</div><div><h4 style="margin:0;color:var(--accent-green)">`+title+`</h4><p style="margin:0;font-size:0.8rem">`+msg+`</p></div>`;
        container.appendChild(t); setTimeout(() => { t.style.opacity = '0'; setTimeout(()=>t.remove(),500); }, 5000);
    }
    setInterval(checkOrderStatus, 5000);

    // --- LOAD MENU (STYLE LAMA) ---
    let currentCategory = 'all';
    function setCategory(cat, btn) { currentCategory = cat; document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active')); btn.classList.add('active'); loadMenu(); }
    
    function loadMenu() {
        fetch('?mode=json').then(r=>r.json()).then(data=>{
            let html = ''; const container = document.querySelector('.food-grid');
            let filtered = (currentCategory !== 'all') ? data.filter(i => i.category === currentCategory) : data;
            if(filtered.length===0) { container.innerHTML='<div style="grid-column: 1/-1; text-align:center; padding:40px;"><h3>Yah, kategori ini kosong! 😭</h3></div>'; return; }
            filtered.forEach(item => {
                let img = (item.imageUrl && item.imageUrl.length > 5) ? item.imageUrl : 'https://dummyimage.com/300x200/333/fff&text=No+Image';
                html += `
                    <div class="food-card">
                        <span class="category-tag">` + item.category + `</span>
                        <img src="` + img + `" class="food-img" alt="` + item.name + `">
                        <div class="food-info">
                            <h3 style="margin-bottom: 5px; color: #fff;">` + item.name + `</h3>
                            <p style="color: var(--text-sec); font-size: 0.9rem; margin-bottom: 20px;">` + item.description + `</p>
                        </div>
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <span class="price">` + rupiah(item.price) + `</span>
                            <a href="cart?action=add&id=` + item.id + `" style="background: #fff; color: #000; width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight:bold; cursor: pointer; text-decoration: none; transition: 0.2s;">+</a>
                        </div>
                    </div>`;
            });
            container.innerHTML = html;
        });
    }
    setInterval(loadMenu, 5000);

    // --- CART ---
    function updateCartItem(id, q) { fetch('cart?action=update&id='+id+'&qty='+q).then(r=>{loadCart()}); }
    function toggleCart() { document.querySelector('.cart-sidebar').classList.toggle('active'); document.querySelector('.overlay').classList.toggle('active'); if(document.querySelector('.cart-sidebar').classList.contains('active')) loadCart(); }
    function loadCart() {
        fetch('cart?action=view&mode=json').then(r=>{if(r.status===401){location.href="login.jsp";return;}return r.json();}).then(d=>{
            const l=document.getElementById('cartList'); const t=document.getElementById('cartTotal');
            if(d.items.length===0){l.innerHTML='<p style="text-align:center;color:#555;margin-top:50px">Masih kosong nih.</p>'; t.innerText=rupiah(0); return;}
            let h=''; d.items.forEach(i=>{ h+=`<div class="cart-item"><img src="`+(i.menu.imageUrl||'https://dummyimage.com/50')+`"><div style="flex:1"><div style="font-weight:bold;font-size:0.9rem">`+i.menu.name+`</div><div style="font-size:0.8rem;color:#888;display:flex;gap:10px;margin-top:5px"><button onclick="updateCartItem(`+i.menu.id+`,-1)" class="qty-btn">-</button><span>`+i.quantity+`</span><button onclick="updateCartItem(`+i.menu.id+`,1)" class="qty-btn">+</button></div></div><div style="font-weight:bold;color:var(--accent-green)">`+rupiah(i.menu.price*i.quantity)+`</div></div>`; });
            l.innerHTML=h; t.innerText=rupiah(d.total);
        });
    }
</script>
</body>
</html>