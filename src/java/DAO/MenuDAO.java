package com.makancuy.dao;

import com.makancuy.model.MenuItem;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MenuDAO {

    // 1. READ SEMUA MENU (Perbaikan nama: getAllMenus)
    public List<MenuItem> getAllMenus() {
        List<MenuItem> list = new ArrayList<>();
        String sql = "SELECT * FROM menu ORDER BY id DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(new MenuItem(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("description"),
                    rs.getDouble("price"),
                    rs.getString("image_url"),
                    rs.getString("category")
                ));
            }
        } catch (SQLException e) { 
            // Kalau koneksi gagal, error akan muncul di Output NetBeans
            System.out.println(">>> ERROR AMBIL MENU: " + e.getMessage());
            e.printStackTrace(); 
        }
        return list;
    }

    // 2. TOTAL PENDAPATAN (SALES)
    public double getTotalPendapatan() {
        double total = 0;
        // Pastikan querynya bener: "FROM orders"
        String sql = "SELECT SUM(total_price) FROM orders WHERE status = 'PAID'"; 
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                total = rs.getDouble(1);
            }
        } catch (SQLException e) { 
            System.out.println(">>> ERROR HITUNG DUIT: " + e.getMessage());
            e.printStackTrace(); 
        }
        return total;
    }

    // ... (CREATE & DELETE biarkan saja seperti sebelumnya) ...
    public void addMenu(MenuItem m) {
        String sql = "INSERT INTO menu (name, description, price, image_url, category) VALUES (?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, m.getName());
            ps.setString(2, m.getDescription());
            ps.setDouble(3, m.getPrice());
            ps.setString(4, m.getImageUrl());
            ps.setString(5, m.getCategory());
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    public void deleteMenu(int id) {
        String sql = "DELETE FROM menu WHERE id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }
}