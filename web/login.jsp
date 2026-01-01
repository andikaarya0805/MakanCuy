<%-- 
    Document   : login
    Created on : Dec 20, 2025, 4:56:40 PM
    Author     : andik
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | MakanCuy</title>
    
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    
    <style>
        /* --- TEMA GEN Z --- */
        :root { --bg: #0d0d0d; --card: #1a1a1a; --accent: #ccff00; --text: #fff; --font: 'Space Grotesk', sans-serif; }
        
        body { 
            background: var(--bg); color: var(--text); font-family: var(--font); 
            display: flex; justify-content: center; align-items: center; 
            min-height: 100vh; margin: 0; 
            padding: 20px; /* Jarak aman biar gak nempel bezel HP */
            box-sizing: border-box;
        }
        
        .login-card {
            background: var(--card); padding: 40px; border-radius: 24px; width: 100%; max-width: 400px;
            border: 1px solid #333; text-align: center; box-shadow: 0 0 30px rgba(0,0,0,0.5);
            position: relative;
        }
        
        /* LOGO BRANDING */
        .logo { font-size: 2.2rem; font-weight: 700; margin-bottom: 5px; letter-spacing: -1px; display: block; text-decoration: none; color: #fff; }
        .logo span { color: var(--accent); }
        
        p.subtitle { color: #888; margin-bottom: 30px; font-size: 0.95rem; }
        
        /* FORM INPUTS */
        input { 
            width: 100%; padding: 15px; margin: 8px 0; background: #000; 
            border: 1px solid #333; color: #fff; border-radius: 12px; 
            box-sizing: border-box; font-family: var(--font); transition: 0.3s; font-size: 1rem;
        }
        input:focus { outline: none; border-color: var(--accent); box-shadow: 0 0 10px rgba(204, 255, 0, 0.1); }
        
        /* BUTTON */
        .btn {
            width: 100%; padding: 15px; background: var(--accent); color: #000; border: none;
            border-radius: 50px; font-weight: bold; font-size: 1rem; cursor: pointer; margin-top: 20px; transition: 0.3s;
        }
        .btn:hover { box-shadow: 0 0 15px rgba(204, 255, 0, 0.4); transform: scale(1.02); }

        /* ALERT STYLES */
        .alert { padding: 12px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; border: 1px solid transparent; text-align: left; }
        .alert-error { background: rgba(255, 71, 87, 0.1); color: #ff4757; border-color: #ff4757; }
        .alert-success { background: rgba(204, 255, 0, 0.1); color: #ccff00; border-color: #ccff00; }
        
        /* LINKS */
        a { text-decoration: none; transition: 0.2s; }
        a:hover { color: #fff; }
        
        .back-link { 
            display: inline-block; margin-bottom: 20px; color: #666; 
            text-decoration: none; font-size: 0.85rem; transition: 0.3s; 
        }
        .back-link:hover { color: var(--accent); }

        /* --- MOBILE RESPONSIVE --- */
        @media (max-width: 480px) {
            .login-card {
                padding: 30px 20px; /* Padding dikurangin di HP biar lega */
            }
            .logo { font-size: 1.8rem; }
            input { padding: 12px; font-size: 0.9rem; }
        }
    </style>
</head>
<body>

    <div class="login-card">
        <a href="index.jsp" class="back-link">← Kembali ke Menu Utama</a>
        
        <div class="logo">Makan<span>Cuy</span>.</div>
        <p class="subtitle">Masuk dulu Boss, baru pesen.</p>

        <% 
            String error = request.getParameter("error");
            String status = request.getParameter("status");
        %>

        <% if ("need_login".equals(error)) { %>
            <div class="alert alert-error">
                ⚠️ Eits! Login dulu ler kalau mau pesan.
            </div>
        <% } %>

        <% if ("true".equals(error)) { %>
            <div class="alert alert-error">
                Username atau Password salah! 😤
            </div>
        <% } %>

        <% if ("registered".equals(status)) { %>
            <div class="alert alert-success">
                Akun berhasil dibuat! Gas login. 🎉
            </div>
        <% } %>

        <form action="auth" method="post">
            <input type="hidden" name="action" value="login">
            
            <input type="text" name="username" placeholder="Username" required autocomplete="off">
            <input type="password" name="password" placeholder="Password" required>
            
            <button type="submit" class="btn">GAS MASUK ➜</button>
        </form>
        
        <div style="margin-top: 25px; font-size: 0.9rem; color: #888;">
            Belum punya akun? 
            <a href="register.jsp" style="color: var(--accent); font-weight: bold;">Daftar Sini</a>
        </div>
    </div>

</body>
</html>