<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Debug Database</title></head>
<body style="font-family: monospace; background: #222; color: #0f0; padding: 20px;">
    <h1>🔍 DIAGNOSA DATABASE</h1>
    <hr>
    <%
        // 1. Setting Koneksi (Sama persis kayak DBConnection.java)
        String url = "jdbc:mysql://localhost:3306/makancuy_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        String user = "root";
        String password = ""; // <-- SESUAIKAN JIKA ADA PASSWORD

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(url, user, password);
            out.println("✅ KONEKSI: SUKSES!<br>");
            out.println("📂 DATABASE NAME: " + conn.getCatalog() + "<br>");
            
            // 2. Cek Jumlah Data
            Statement stmt = conn.createStatement();
            ResultSet rsCount = stmt.executeQuery("SELECT COUNT(*) FROM menu");
            rsCount.next();
            int jumlah = rsCount.getInt(1);
            out.println("📊 JUMLAH DATA DI TABEL 'MENU': " + jumlah + "<br>");
            
            // 3. KALAU KOSONG, KITA PAKSA ISI (AUTO FIX)
            if (jumlah == 0) {
                out.println("<br>⚠️ DATA KOSONG! MENCOBA INSERT OTOMATIS...<br>");
                String sqlInsert = "INSERT INTO menu (name, description, price, image_url, category) VALUES " +
                    "('Auto Burger', 'Burger hasil inject debug', 30000, '', 'Makanan'), " +
                    "('Auto Kopi', 'Kopi hasil inject debug', 15000, '', 'Minuman')";
                
                int rows = stmt.executeUpdate(sqlInsert);
                out.println("✅ BERHASIL INSERT " + rows + " DATA BARU!<br>");
                out.println("👉 Silakan refresh halaman utama sekarang.<br>");
            } else {
                // 4. TAMPILKAN DATA YANG ADA
                out.println("<br>📋 DAFTAR DATA YANG DITEMUKAN:<br>");
                out.println("------------------------------------------------<br>");
                ResultSet rsData = stmt.executeQuery("SELECT * FROM menu");
                while(rsData.next()) {
                    out.println("ID: " + rsData.getInt("id") + " | " + 
                                rsData.getString("name") + " | " + 
                                rsData.getString("category") + "<br>");
                }
            }
            conn.close();
            
        } catch (Exception e) {
            out.println("<h2 style='color:red'>❌ ERROR FATAL:</h2>");
            e.printStackTrace(new java.io.PrintWriter(out));
        }
    %>
</body>
</html>