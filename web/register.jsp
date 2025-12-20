<%-- 
    Document   : register
    Created on : Dec 20, 2025, 4:59:31 PM
    Author     : andik
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Daftar Akun | MakanCuy</title>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;500;700&display=swap" rel="stylesheet">
    <style>
        body { background: #0d0d0d; color: #fff; font-family: 'Space Grotesk', sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
        .box { background: #1a1a1a; padding: 40px; border-radius: 20px; width: 100%; max-width: 400px; border: 1px solid #333; text-align: center; }
        input { width: 100%; padding: 12px; margin: 10px 0; background: #000; border: 1px solid #333; color: #fff; border-radius: 8px; box-sizing: border-box; }
        .btn { background: #ccff00; color: #000; width: 100%; padding: 12px; border: none; border-radius: 50px; font-weight: bold; cursor: pointer; margin-top: 20px; font-size: 1rem; }
        .btn:hover { box-shadow: 0 0 15px rgba(204,255,0,0.5); }
        a { color: #ccff00; text-decoration: none; }
    </style>
</head>
<body>
    <div class="box">
        <h1 style="margin-bottom: 5px;">Join Us! 🚀</h1>
        <p style="color: #888; margin-bottom: 30px;">Bikin akun biar bisa jajan.</p>

        <form action="auth" method="POST">
            <input type="hidden" name="action" value="register">
            
            <div style="text-align: left; font-size: 0.9rem; color: #ccc;">Username</div>
            <input type="text" name="username" required placeholder="Pilih username keren">
            
            <div style="text-align: left; font-size: 0.9rem; color: #ccc;">Password</div>
            <input type="password" name="password" required placeholder="Rahasia negara">
            
            <button type="submit" class="btn">DAFTAR SEKARANG</button>
        </form>
        
        <p style="margin-top: 20px; font-size: 0.9rem;">
            Udah punya akun? <a href="login.jsp">Login sini</a>
        </p>
    </div>
</body>
</html>