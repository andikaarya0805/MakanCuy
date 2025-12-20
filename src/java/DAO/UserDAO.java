package com.makancuy.dao;

import util.DBConnection; // <--- Perbaikan di sini (hapus 's' pada utils)
import java.sql.*;
import com.makancuy.model.User;

public class UserDAO {

    // Ganti checkLogin biasa dengan ini:
    public User login(String username, String password) {
        User user = null;
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ps.setString(2, password); // Ingat, di real project password harus di-hash!
            
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // KETEMU! Bungkus datanya ke dalam object User
                user = new User();
                user.setId(rs.getInt("id"));       // PENTING: ID buat Cart
                user.setUsername(rs.getString("username"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role")); // PENTING: Buat bedain Admin/Cust
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user; // Kalau gagal login, ini isinya null  
    }
    
    // --- FITUR REGISTER ---
    public void registerUser(String username, String password) {
        // Default role pas daftar adalah 'user' (bukan admin)
        String sql = "INSERT INTO users (username, password, role) VALUES (?, ?, 'user')";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, username);
            ps.setString(2, password);
            ps.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}