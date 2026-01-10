<%-- 
    Document   : index
    Created on : Dec 20, 2025
    Author     : andik
    Updated    : Jan 05, 2026 (FIX: Force Save Notes before Checkout)
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
    
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    
    <style>
        /* --- 1. CORE STYLE (JANGAN DIUBAH) --- */
        :root { --bg-color: #0d0d0d; --card-bg: #1a1a1a; --text-main: #ffffff; --text-sec: #a1a1a1; --accent-green: #ccff00; --font-main: 'Space Grotesk', sans-serif; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background-color: var(--bg-color); color: var(--text-main); font-family: var(--font-main); overflow-x: hidden; }

        .container { max-width: 1200px; margin: 0 auto; padding: 0 20px; }
        .btn { padding: 12px 32px; border-radius: 50px; font-weight: 700; cursor: pointer; border: none; transition: 0.3s; text-decoration: none; display: inline-block; }
        .btn-primary { background-color: var(--accent-green); color: #000; }
        .btn-primary:hover { transform: scale(1.05); box-shadow: 0 0 20px rgba(204, 255, 0, 0.4); }

        /* NAVBAR */
        nav { display: flex; justify-content: space-between; align-items: center; padding: 25px 0; position: relative; z-index: 1000; }
        .logo { font-size: 1.8rem; font-weight: 700; letter-spacing: -1px; }
        .logo span { color: var(--accent-green); }
        .nav-group { display: flex; align-items: center; gap: 20px; }
        .nav-links { display: flex; gap: 20px; align-items: center; list-style: none; }
        .nav-links a { color: var(--text-sec); text-decoration: none; font-weight: 500; transition: 0.3s; font-size: 0.95rem; }
        .nav-links a:hover { color: var(--accent-green); }
        .hamburger { display: none; font-size: 1.8rem; cursor: pointer; color: #fff; background: none; border: none; }

        /* --- 2. HERO SECTION --- */
        .hero { display: flex; align-items: center; justify-content: space-between; min-height: 60vh; margin-bottom: 50px; }
        .hero h1 { font-size: 4rem; line-height: 1; margin-bottom: 20px; letter-spacing: -2px; }
        .hero h1 span { -webkit-text-stroke: 1px var(--accent-green); color: transparent; }
        .hero p { color: var(--text-sec); margin-bottom: 30px; max-width: 500px; line-height: 1.6; } 
        .hero-img img { width: 350px; height: 350px; object-fit: cover; border-radius: 50%; border: 2px solid var(--accent-green); animation: float 6s ease-in-out infinite; }

        /* GRID MENU */
        .food-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 100px; }
        .food-card { background: var(--card-bg); border-radius: 24px; padding: 15px; border: 1px solid #333; transition: 0.3s; position: relative; height: 100%; display: flex; flex-direction: column; justify-content: space-between; }
        .food-card:hover { transform: translateY(-5px); border-color: var(--accent-green); }
        .food-img { width: 100%; height: 180px; object-fit: cover; border-radius: 16px; margin-bottom: 15px; }
        .category-tag { position: absolute; top: 10px; right: 10px; background: rgba(0,0,0,0.7); color: #fff; padding: 4px 10px; border-radius: 20px; font-size: 0.7rem; }
        .price { color: var(--accent-green); font-weight: 700; font-size: 1.1rem; }

        .filter-container { display: flex; gap: 10px; margin-bottom: 30px; overflow-x: auto; padding-bottom: 10px; -webkit-overflow-scrolling: touch; }
        .filter-btn { background: var(--card-bg); border: 1px solid #333; color: var(--text-sec); padding: 8px 20px; border-radius: 50px; cursor: pointer; transition: 0.3s; font-family: var(--font-main); font-weight: 500; white-space: nowrap; font-size: 0.9rem; }
        .filter-btn:hover, .filter-btn.active { background: var(--accent-green); color: #000; border-color: var(--accent-green); }

        /* --- 3. UI BUTTONS --- */
        .float-btn { position: fixed; width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; cursor: pointer; z-index: 1000; transition: transform 0.3s; border: none; }
        .float-btn:hover { transform: scale(1.1); }
        .gacha-btn { bottom: 30px; left: 30px; background: #fff; color: #000; border: 2px solid var(--accent-green); }
        .chat-btn { bottom: 100px; right: 30px; background: #222; color: var(--accent-green); border: 1px solid var(--accent-green); }
        .cart-btn { bottom: 30px; right: 30px; background: var(--accent-green); color: #000; width: 60px; height: 60px; font-size: 1.8rem; box-shadow: 0 0 20px rgba(204, 255, 0, 0.5); }

        /* --- 4. SIDEBAR (FIXED FLEXBOX) --- */
        .cart-sidebar { 
            position: fixed; top: 0; right: -400px; width: 350px; max-width: 85%; height: 100vh; 
            background: #111; padding: 25px; z-index: 2000; transition: 0.4s; 
            display: flex; flex-direction: column; 
            border-left: 1px solid #333; 
        }
        .cart-sidebar.active { right: 0; }
        .overlay { position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.8); backdrop-filter: blur(5px); z-index:1500; display:none; }
        .overlay.active { display:block; }
        
        .cart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid #333; padding-bottom: 10px; flex-shrink: 0; }
        
        /* FIX: Cart Item ambil sisa ruang (flex: 1) biar gak gepeng */
        .cart-items { flex: 1; overflow-y: auto; margin-bottom: 20px; min-height: 0; }
        .cart-item { display: flex; gap: 10px; margin-bottom: 15px; background: #222; padding: 10px; border-radius: 10px; flex-direction: column; }
        .cart-row-main { display: flex; gap: 10px; width: 100%; align-items: center; }
        .cart-item img { width: 50px; height: 50px; border-radius: 5px; object-fit: cover; }
        .qty-btn { background: #333; color: #fff; width: 25px; height: 25px; border-radius: 5px; border: none; cursor: pointer; font-weight: bold; display: inline-flex; align-items: center; justify-content: center; transition: 0.2s; }
        
        .cart-footer-area { flex-shrink: 0; }

        /* NOTE INPUT & VOUCHER */
        .note-input { background: #111; border: 1px solid #444; color: #aaa; width: 100%; padding: 5px 10px; border-radius: 8px; font-size: 0.8rem; margin-top: 8px; font-family: inherit; }
        .note-input:focus { border-color: var(--accent-green); color: #fff; outline: none; }
        .voucher-box { display: flex; gap: 5px; margin: 10px 0; }
        .voucher-input { flex: 1; background: #222; border: 1px solid #444; color: #fff; padding: 8px; border-radius: 8px; }
        .btn-apply { background: #444; color: #fff; border: none; padding: 0 15px; border-radius: 8px; cursor: pointer; font-weight: bold; }

        .marquee-container { background: var(--accent-green); color: #000; padding: 15px 0; transform: rotate(-2deg); width: 105%; margin-left: -10px; margin-bottom: 50px; overflow: hidden; white-space: nowrap; }
        .marquee-content { display: inline-block; font-weight: 900; font-size: 1.5rem; text-transform: uppercase; animation: scroll 20s linear infinite; }

        /* --- 5. CHAT DESKTOP (Floating) --- */
        .chat-widget { position: fixed; bottom: 100px; right: 90px; width: 300px; height: 400px; background: #1a1a1a; border: 1px solid var(--accent-green); border-radius: 15px; z-index: 2000; display: none; flex-direction: column; box-shadow: 0 5px 20px rgba(0,0,0,0.5); overflow: hidden; animation: slideUp 0.3s; }
        .chat-widget.active { display: flex; }
        .chat-header { background: var(--accent-green); color: #000; padding: 12px; font-weight: bold; display: flex; justify-content: space-between; align-items: center; }
        .chat-body { flex: 1; padding: 10px; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; }
        .chat-footer { padding: 10px; border-top: 1px solid #333; display: flex; gap: 5px; }
        .chat-input { flex: 1; background: #000; border: 1px solid #333; color: #fff; padding: 8px; border-radius: 5px; }

        .msg { padding: 6px 10px; border-radius: 6px; font-size: 0.8rem; max-width: 90%; word-wrap: break-word; }
        .msg.admin { background: #333; color: #ccc; align-self: flex-start; }
        .msg.user { background: var(--accent-green); color: #000; align-self: flex-end; }

        /* --- 6. CHAT MOBILE (Inside Sidebar) --- */
        .sidebar-chat { border-top: 1px dashed #333; margin-top: 30px; padding-top: 20px; display: none; } 
        
        @keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        @keyframes float { 0%, 100% { transform: translateY(0px); } 50% { transform: translateY(-20px); } }
        @keyframes scroll { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }

        /* --- 7. RESPONSIVE --- */
        @media (max-width: 768px) { 
            .marquee-container { display: none; }
            .food-grid { grid-template-columns: repeat(2, 1fr); }
            .nav-links { display: none; position: absolute; top: 80px; left: 0; right: 0; background: #111; flex-direction: column; padding: 20px; }
            .nav-links.active { display: flex; }
            .hamburger { display: block; }
            
            .hero { flex-direction: column-reverse; text-align: center; justify-content: center; gap: 30px; margin-top: 20px; }
            .hero h1 { font-size: 2.5rem; }
            .hero-img img { width: 220px; height: 220px; margin: 0 auto; }

            .chat-btn, .chat-widget { display: none !important; } 
            .sidebar-chat { display: block; } 
        }
    </style>
</head>
<body>

    <div class="container">
        <nav>
            <div class="logo">Makan<span>Cuy</span>.</div>
            <div class="nav-group">
                <div class="nav-links" id="navLinks">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user}">
                            <span style="color: var(--accent-green); font-weight: bold;">${sessionScope.user.username} 👋</span>
                            <a href="history">📦 Status</a>
                            <a href="auth" style="color: #ff4757;">Logout</a>
                        </c:when>
                        <c:otherwise><a href="login.jsp" style="color: #111" class="btn btn-primary" style="padding: 8px 24px;">Login</a></c:otherwise>
                    </c:choose>
                </div>
                <button class="hamburger" onclick="toggleMenu()">☰</button>
            </div>
        </nav>

        <section class="hero">
            <div>
                <h1>PERUT<br><span>KOSONG?</span><br>GASLAH.</h1>
                <p style="color: var(--text-sec); margin-bottom: 30px;">
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
                • JANGAN BIARKAN LAPAR MENGGANGGU SKRIPSI • DISKON 30% UNTUK SOBAT AMBYAR • DIMSUM • BASRENG • AYAM GEPREK • ES KOPI SUSU GULA AREN •
                • JANGAN BIARKAN LAPAR MENGGANGGU SKRIPSI • DISKON 30% UNTUK SOBAT AMBYAR • DIMSUM • BASRENG • AYAM GEPREK • ES KOPI SUSU GULA AREN •
            </div>
        </div>

        <h2 id="menu" style="font-size: 2.5rem; margin-bottom: 30px;">Menu Hype 🔥</h2>
        
        <div class="filter-container">
            <button class="filter-btn active" onclick="setCategory('all', this)">Semua</button>
            <button class="filter-btn" onclick="setCategory('Makanan', this)">Makanan</button>
            <button class="filter-btn" onclick="setCategory('Minuman', this)">Minuman</button>
        </div>

        <div class="food-grid">
            <c:forEach items="${genZMenu}" var="item">
                <div class="food-card">
                    <span class="category-tag">${item.category}</span>
                    <c:set var="gambar" value="${item.imageUrl}" />
                    <c:if test="${empty gambar}"><c:set var="gambar" value="https://dummyimage.com/300x200/333/fff" /></c:if>
                    <img src="${gambar}" class="food-img" alt="${item.name}">
                    <div class="food-info">
                        <h3 style="color:#fff">${item.name}</h3>
                        <p style="color:#888;font-size:0.9rem">${item.description}</p>
                    </div>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-top:15px;">
                        <span class="price"><fmt:setLocale value="id_ID"/><fmt:formatNumber value="${item.price}" type="currency" currencySymbol="Rp " maxFractionDigits="0"/></span>
                        <a href="cart?action=add&id=${item.id}" style="background:#fff; color:#000; width:40px; height:40px; border-radius:50%; display:flex; align-items:center; justify-content:center; text-decoration:none; font-weight:bold">+</a>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <button class="float-btn gacha-btn" onclick="spinGacha()" title="Gacha">🎲</button>
    <button class="float-btn chat-btn" onclick="toggleDesktopChat()" title="Chat Admin">💬</button>
    <button class="float-btn cart-btn" onclick="toggleCart()">🛒</button>
    
    <div class="overlay" onclick="closeAll()"></div>

    <div class="chat-widget" id="desktopChatWidget">
        <div class="chat-header">
            <span>Admin Dapur 👨‍🍳</span>
            <span onclick="toggleDesktopChat()" style="cursor:pointer">×</span>
        </div>
        <div class="chat-body" id="desktopChatBody">
            <div class="msg admin">Halo! Ada yang bisa dibantu?</div>
        </div>
        <div class="chat-footer">
            <input type="text" id="desktopChatInput" class="chat-input" placeholder="Tulis pesan..." onkeypress="handleChatEnter(event, 'desktop')">
            <button onclick="sendChat('desktop')" style="background: var(--accent-green); border: none; padding: 0 12px; border-radius: 6px; cursor: pointer;">➤</button>
        </div>
    </div>

    <div class="cart-sidebar">
        <div class="cart-header"><h2>Keranjang</h2><span onclick="toggleCart()" style="cursor:pointer;font-size:1.5rem">×</span></div>
        
        <div class="cart-items" id="cartList"><p style="text-align:center;color:#555;margin-top:20px">Masih kosong.</p></div>
        
        <div class="cart-footer-area">
            <div class="voucher-box">
                <input type="text" id="voucherCode" class="voucher-input" placeholder="Kode Promo">
                <button onclick="applyVoucher()" class="btn-apply">Apply</button>
            </div>

            <div style="margin-bottom: 20px;">
                <div style="display:flex; justify-content:space-between; margin-bottom:5px;">
                    <span style="color:#aaa">Diskon:</span><span id="discountDisplay" style="color:#ff4757">-Rp 0</span>
                </div>
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                    <span>Total:</span><span id="cartTotal" style="font-size:1.5rem; font-weight:bold; color:var(--accent-green);">Rp 0</span>
                </div>
                <a href="javascript:void(0)" onclick="handleCheckout()" class="btn btn-primary" style="width:100%; text-align:center;">CHECKOUT ➔</a>
            </div>

            <div class="sidebar-chat mobile-only">
                <h4 style="margin-bottom: 10px; color: #888; font-size: 0.9rem;">Chat Dapur 👨‍🍳</h4>
                <div class="chat-body" id="mobileChatBody" style="height: 120px; background: #000; border: 1px solid #333; border-radius: 8px; margin-bottom: 10px; overflow-y: auto;">
                    <div class="msg admin">Halo! Butuh bantuan?</div>
                </div>
                <div style="display: flex; gap: 5px;">
                    <input type="text" id="mobileChatInput" placeholder="Tulis pesan..." style="flex: 1; background: #222; border: 1px solid #444; color: #fff; padding: 8px; border-radius: 6px;" onkeypress="handleChatEnter(event, 'mobile')">
                    <button onclick="sendChat('mobile')" style="background: var(--accent-green); border: none; padding: 0 12px; border-radius: 6px; cursor: pointer;">➤</button>
                </div>
            </div>
        </div>
    </div>

<script>
    function toggleMenu() { document.getElementById('navLinks').classList.toggle('active'); }
    function toggleCart() { document.querySelector('.cart-sidebar').classList.toggle('active'); document.querySelector('.overlay').classList.toggle('active'); if(document.querySelector('.cart-sidebar').classList.contains('active')) loadCart(); }
    function toggleDesktopChat() { document.getElementById('desktopChatWidget').classList.toggle('active'); }
    function closeAll() { document.querySelector('.cart-sidebar').classList.remove('active'); document.getElementById('desktopChatWidget').classList.remove('active'); document.querySelector('.overlay').classList.remove('active'); }
    const rupiah = (n) => new Intl.NumberFormat("id-ID", {style: "currency", currency: "IDR", minimumFractionDigits: 0}).format(n);

    // --- CART SYSTEM ---
    let currentTotal = 0, activeDiscount = 0;
    function updateCartItem(id, q) { fetch('cart?action=update&id='+id+'&qty='+q).then(()=>loadCart()); }
    
    // NOTE FIXED: Pakai onblur biar kesimpen pas klik checkout
    function updateCartNote(id, text) { fetch('cart?action=update_note&id=' + id + '&notes=' + encodeURIComponent(text)); }
    
    function applyVoucher() {
        const code = document.getElementById('voucherCode').value;
        fetch('cart?action=check_voucher&code=' + code).then(res => res.json()).then(data => {
            if (data.discount > 0) { activeDiscount = data.discount; Swal.fire("Mantap!", "Diskon " + data.discount + "% aktif!", "success"); } 
            else { activeDiscount = 0; Swal.fire("Gagal", "Kode salah!", "error"); }
            calculateFinalTotal();
        });
    }
    function calculateFinalTotal() {
        let discountAmount = (currentTotal * activeDiscount) / 100;
        document.getElementById('discountDisplay').innerText = "- " + rupiah(discountAmount);
        document.getElementById('cartTotal').innerText = rupiah(currentTotal - discountAmount);
    }
    
    function loadCart() {
        fetch('cart?action=view&mode=json').then(r=>{if(r.status===401){location.href="login.jsp";return;}return r.json();}).then(d=>{
            const l=document.getElementById('cartList'); 
            if(d.items.length===0){ l.innerHTML='<p style="text-align:center;color:#555">Kosong.</p>'; currentTotal=0; calculateFinalTotal(); return;}
            let h=''; 
            d.items.forEach(i=>{ 
                h+=`<div class="cart-item">
                        <div class="cart-row-main">
                            <img src="`+(i.menu.imageUrl||'https://dummyimage.com/50')+`">
                            <div style="flex:1">
                                <div style="font-weight:bold;font-size:0.9rem">`+i.menu.name+`</div>
                                <div style="display:flex;gap:10px;margin-top:5px">
                                    <button onclick="updateCartItem(`+i.menu.id+`,-1)" class="qty-btn">-</button><span>`+i.quantity+`</span><button onclick="updateCartItem(`+i.menu.id+`,1)" class="qty-btn">+</button>
                                </div>
                            </div>
                            <div style="color:var(--accent-green)">`+rupiah(i.menu.price*i.quantity)+`</div>
                        </div>
                        <input type="text" class="note-input" value="`+(i.notes||'')+`" placeholder="Catatan..." onblur="updateCartNote(`+i.menu.id+`, this.value)">
                    </div>`; 
            });
            l.innerHTML=h; currentTotal = d.total; calculateFinalTotal();
        });
    }

    // --- CHECKOUT HANDLER (DELAY FOR NOTE SAVING) ---
    function handleCheckout() {
        // Blur element aktif biar onblur jalan dulu
        if (document.activeElement) { document.activeElement.blur(); }

        Swal.fire({
            title: 'Memproses...',
            text: 'Menyimpan pesananmu...',
            timer: 500, // Delay 0.5 detik
            showConfirmButton: false,
            background: '#1a1a1a', color: '#fff',
            didOpen: () => { Swal.showLoading() }
        }).then(() => {
            window.location.href = "Checkout.jsp";
        });
    }

    // --- CHAT LOGIC ---
    function handleChatEnter(e, source) { if(e.key === 'Enter') sendChat(source); }
    function sendChat(source) {
        let inputId = source === 'desktop' ? 'desktopChatInput' : 'mobileChatInput';
        const input = document.getElementById(inputId);
        const msg = input.value;
        if(!msg) return;
        
        const formData = new URLSearchParams();
        formData.append('action', 'send');
        formData.append('message', msg);
        
        fetch('chat', { method: 'POST', body: formData }).then(() => {
            input.value = "";
            loadUserMessages();
        });
    }

    function loadUserMessages() {
        fetch('chat?action=get_messages').then(r=>r.json()).then(data => {
            const containers = ['desktopChatBody', 'mobileChatBody'];
            let html = '';
            data.forEach(msg => {
                let cls = (msg.sender === 'user') ? 'user' : 'admin'; 
                html += `<div class="msg `+cls+`">`+msg.message+`</div>`;
            });
            containers.forEach(id => {
                const body = document.getElementById(id);
                if(body && body.innerHTML !== html) { body.innerHTML = html; body.scrollTop = body.scrollHeight; }
            });
        });
    }
    setInterval(loadUserMessages, 1000);
    loadUserMessages();

    // --- GACHA & MENU ---
    function spinGacha() {
        fetch('?mode=json').then(r=>r.json()).then(data=>{
            const rand = data[Math.floor(Math.random()*data.length)];
            Swal.fire({
                title: '✨ Takdir Memilih!', text: rand.name, imageUrl: rand.imageUrl, imageWidth: 300,
                confirmButtonText: 'Pesen!', confirmButtonColor: '#ccff00', background: '#1a1a1a', color: '#fff'
            }).then(r=>{ if(r.isConfirmed) window.location.href="cart?action=add&id="+rand.id; });
        });
    }
    
    let currentCategory = 'all';
    function setCategory(cat, btn) { currentCategory = cat; document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active')); btn.classList.add('active'); loadMenu(); }
    function loadMenu() {
        fetch('?mode=json').then(r=>r.json()).then(data=>{
            let h = ''; const c = document.querySelector('.food-grid');
            let f = (currentCategory !== 'all') ? data.filter(i => i.category === currentCategory) : data;
            f.forEach(i => {
                h += `<div class="food-card"><span class="category-tag">`+i.category+`</span><img src="`+(i.imageUrl||'https://dummyimage.com/200')+`" class="food-img"><div class="food-info"><h3 style="color:#fff">`+i.name+`</h3></div><div style="display:flex;justify-content:space-between;margin-top:10px"><span class="price">`+rupiah(i.price)+`</span><a href="cart?action=add&id=`+i.id+`" style="background:#fff;color:#000;width:35px;height:35px;border-radius:50%;display:flex;align-items:center;justify-content:center;text-decoration:none;font-weight:bold">+</a></div></div>`;
            });
            c.innerHTML = h;
        });
    }
    loadMenu();
    
    // Status Check
    let lastStatus = localStorage.getItem('lastStatus') || ""; let lastOrderId = localStorage.getItem('lastOrderId') || 0;
    setInterval(() => {
        const timeParams = new Date().getTime(); 
        fetch('api/user-status?nocache=' + timeParams).then(res => res.json()).then(data => {
            if (!data.status) return;
            if (data.status !== lastStatus || data.orderId != lastOrderId) {
                let title = "", icon = "info";
                if (data.status === 'PROCESSING') { title = "👨‍🍳 Sedang Dimasak"; } else if (data.status === 'DELIVERING') { title = "🛵 Sedang Diantar"; icon="success"; } else if (data.status === 'COMPLETED') { title = "✅ Pesanan Selesai"; icon="success"; }
                if (title !== "") Swal.fire({ toast: true, position: 'top-end', showConfirmButton: false, timer: 3000, background: '#1a1a1a', color: '#fff', icon: icon, title: title });
                lastStatus = data.status; lastOrderId = data.orderId;
                localStorage.setItem('lastStatus', lastStatus); localStorage.setItem('lastOrderId', lastOrderId);
            }
        }).catch(e=>{});
    }, 1000);
</script>
</body>
</html>