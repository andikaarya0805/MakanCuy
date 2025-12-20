package com.makancuy.dao;

import com.makancuy.model.CartItem;
import com.makancuy.model.MenuItem;
import com.makancuy.model.Order; 

     
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    // 1. Ambil Data Header Order
    public String[] getOrderHeader(int orderId) {
        String[] data = new String[4];
        String sql = "SELECT order_date, total_price, payment_method, status FROM orders WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                data[0] = rs.getString("order_date");
                data[1] = rs.getString("total_price");
                data[2] = rs.getString("payment_method");
                data[3] = rs.getString("status");
            }
        } catch (Exception e) { e.printStackTrace(); }
        return data;
    }

    // 2. Ambil Detail Barang (SOLUSI ERROR DI SINI)
    public List<CartItem> getOrderDetails(int orderId) {
        List<CartItem> list = new ArrayList<>();
        String sql = "SELECT m.name, m.price, oi.quantity " +
                     "FROM order_items oi " +
                     "JOIN menu m ON oi.menu_id = m.id " +
                     "WHERE oi.order_id = ?";
                     
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                MenuItem m = new MenuItem();
                m.setName(rs.getString("name"));
                m.setPrice(rs.getDouble("price"));
                
                // FIX ERROR: Tambahin 0 di parameter pertama
                CartItem item = new CartItem(0, m, rs.getInt("quantity"));
                list.add(item);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    // --- FITUR LAPORAN ADMIN ---
    
    // 1. Ambil List Transaksi Berdasarkan Filter Waktu
    public List<Order> getOrdersByPeriod(String period) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.id, u.username, o.total_price, o.payment_method, o.order_date " +
                     "FROM orders o JOIN users u ON o.user_id = u.id ";
        
        // Tambah filter WHERE sesuai request
        if ("today".equals(period)) {
            sql += "WHERE DATE(o.order_date) = CURDATE() ";
        } else if ("week".equals(period)) {
            sql += "WHERE YEARWEEK(o.order_date, 1) = YEARWEEK(CURDATE(), 1) ";
        } else if ("month".equals(period)) {
            sql += "WHERE MONTH(o.order_date) = MONTH(CURDATE()) AND YEAR(o.order_date) = YEAR(CURDATE()) ";
        }
        
        sql += "ORDER BY o.order_date DESC"; // Urutkan dari yang terbaru

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(new Order(
                    rs.getInt("id"),
                    rs.getString("username"),
                    rs.getDouble("total_price"),
                    rs.getString("payment_method"),
                    rs.getTimestamp("order_date")
                ));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 2. Hitung Total Pendapatan Sesuai Filter
    public double getRevenueByPeriod(String period) {
        double total = 0;
        String sql = "SELECT SUM(total_price) FROM orders WHERE status = 'PAID' ";
        
        if ("today".equals(period)) {
            sql += "AND DATE(order_date) = CURDATE()";
        } else if ("week".equals(period)) {
            sql += "AND YEARWEEK(order_date, 1) = YEARWEEK(CURDATE(), 1)";
        } else if ("month".equals(period)) {
            sql += "AND MONTH(order_date) = MONTH(CURDATE()) AND YEAR(order_date) = YEAR(CURDATE())";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) total = rs.getDouble(1);
        } catch (Exception e) { e.printStackTrace(); }
        return total;
    }
}