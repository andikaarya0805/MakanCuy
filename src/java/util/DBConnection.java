package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // LOGIKA CERDAS:
    // 1. Cek apakah ada 'MYSQLHOST' (Bawaan Railway)? Kalau ada, pakai itu.
    // 2. Kalau gak ada, cek 'DB_HOST' (Custom)?
    // 3. Kalau gak ada juga, baru balik ke 'localhost'.

    private static final String DB_HOST = 
        System.getenv("MYSQLHOST") != null ? System.getenv("MYSQLHOST") : 
        (System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : "localhost");

    private static final String DB_PORT = 
        System.getenv("MYSQLPORT") != null ? System.getenv("MYSQLPORT") : 
        (System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : "3306");

    private static final String DB_NAME = 
        System.getenv("MYSQLDATABASE") != null ? System.getenv("MYSQLDATABASE") : 
        (System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : "makancuy_db");

    private static final String DB_USER = 
        System.getenv("MYSQLUSER") != null ? System.getenv("MYSQLUSER") : 
        (System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root");

    private static final String DB_PASSWORD = 
        System.getenv("MYSQLPASSWORD") != null ? System.getenv("MYSQLPASSWORD") : 
        (System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "");

    // URL JDBC
    private static final String URL = 
            "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME + 
            "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Jakarta";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Debugging (Opsional: Bisa dihapus kalau production)
            // System.out.println("Connecting to: " + DB_HOST + ":" + DB_PORT);
            return DriverManager.getConnection(URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver MySQL gagal diload", e);
        }
    }
}