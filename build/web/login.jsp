<%-- 
    Document   : login
    Created on : Dec 20, 2025, 1:29:11 PM
    Author     : andik
--%>
<% 
    String error = request.getParameter("error");
    if ("need_login".equals(error)) {
%>
    <div style="background: #ffcccc; color: #990000; padding: 10px; margin-bottom: 10px; border-radius: 5px; text-align: center;">
        ⚠️ Eits! Login dulu ler kalau mau pesan.
    </div>
<% } %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Login Admin - MakanCuy</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    <style>
        :root { --bg: #0d0d0d; --card: #1a1a1a; --accent: #ccff00; --text: #fff; --font: 'Space Grotesk', sans-serif; }
        body { background: var(--bg); color: var(--text); font-family: var(--font); display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        
        .login-card {
            background: var(--card); padding: 40px; border-radius: 24px; width: 100%; max-width: 400px;
            border: 1px solid #333; text-align: center; box-shadow: 0 0 30px rgba(0,0,0,0.5);
        }
        
        h1 { margin-bottom: 10px; font-size: 2rem; }
        input { width: 100%; padding: 15px; margin: 10px 0; background: #000; border: 1px solid #333; color: #fff; border-radius: 12px; box-sizing: border-box; font-family: var(--font); }
        input:focus { outline: none; border-color: var(--accent); }
        
        .btn {
            width: 100%; padding: 15px; background: var(--accent); color: #000; border: none;
            border-radius: 50px; font-weight: bold; font-size: 1rem; cursor: pointer; margin-top: 10px; transition: 0.3s;
        }
        .btn:hover { box-shadow: 0 0 15px rgba(204, 255, 0, 0.4); transform: scale(1.02); }

        /* ALERT STYLES */
        .alert { padding: 12px; border-radius: 8px; margin-bottom: 20px; font-size: 0.9rem; border: 1px solid transparent; }
        .alert-error { background: rgba(255, 71, 87, 0.1); color: #ff4757; border-color: #ff4757; }
        .alert-success { background: rgba(204, 255, 0, 0.1); color: #ccff00; border-color: #ccff00; }
        
        a { text-decoration: none; transition: 0.2s; }
        a:hover { color: #fff; }
    </style>
</head>
<body>

    <div class="login-card">
        <h1>🤲️ batas suci </h1>
        <p style="color: #aaa; margin-bottom: 30px;">Login dulu, Boss.</p>
        
        <% if ("need_login".equals(request.getParameter("error"))) { %>
            <div class="alert alert-error">
                ⚠️ Eits! Login dulu ler kalau mau pesan.
            </div>
        <% } %>

        <% if ("true".equals(request.getParameter("error"))) { %>
            <div class="alert alert-error">
                Username atau Password salah! 😤
            </div>
        <% } %>

        <% if ("registered".equals(request.getParameter("status"))) { %>
            <div class="alert alert-success">
                Akun berhasil dibuat! Gas login. 🎉
            </div>
        <% } %>

        <form action="auth" method="post">
            <input type="hidden" name="action" value="login">
            
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit" class="btn">GAS MASUK ➜</button>
        </form>
        
        <div style="margin-top: 25px; font-size: 0.9rem; color: #888;">
            Belum punya akun? 
            <a href="register.jsp" style="color: var(--accent); font-weight: bold;">Daftar Sini</a>
        </div>

        <br>
        <div style="border-top: 1px solid #333; padding-top: 20px;">
            <a href="./" style="color: #555; font-size: 0.8rem;">← Balik ke Menu Utama</a>
        </div>
    </div>

</body>
</html>