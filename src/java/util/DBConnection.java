package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    
    // UPDATE BAGIAN INI:
    private static final String URL = "jdbc:mysql://localhost:3306/makancuy_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Jakarta";
    
    private static final String USER = "root";
    private static final String PASSWORD = ""; 

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver MySQL Gagal Diload!", e);
        }
    }
}