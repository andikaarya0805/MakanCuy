package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // --- KITA PAKSA PAKE DATA RAILWAY LU DI SINI ---
    // (Data ini gw ambil dari screenshot Railway lu tadi)
    
    private static final String DB_HOST = "trolley.proxy.rlwy.net"; 
    private static final String DB_PORT = "39351"; // Jangan 3306!
    private static final String DB_NAME = "railway"; // Nama DB default Railway biasanya 'railway'
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "nSnoluyyZrRueZOqXxvJCJJutVPHXxua";

    // URL JDBC
    private static final String URL =
            "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME +
            "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Jakarta";

    public static Connection getConnection() throws SQLException {
        try {
            // Cek driver dulu
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Konek!
            return DriverManager.getConnection(URL, DB_USER, DB_PASSWORD);
            
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver MySQL tidak ditemukan!", e);
        }
    }
}