package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String DB_HOST =
            System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : "localhost";

    private static final String DB_PORT =
            System.getenv("DB_PORT") != null ? System.getenv("DB_PORT") : "3306";

    private static final String DB_NAME =
            System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : "makancuy_db";

    private static final String DB_USER =
            System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";

    private static final String DB_PASSWORD =
            System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "";

    private static final String URL =
            "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME +
            "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Jakarta";

    public static Connection getConnection() throws SQLException {
        try {
            
            System.out.println("DEBUG: Mencoba konek ke DB Railway...");
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver MySQL gagal diload", e);
        }
    }
}
