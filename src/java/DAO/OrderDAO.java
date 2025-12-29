package com.makancuy.dao;

import com.makancuy.model.CartItem;
import com.makancuy.model.MenuItem;
import com.makancuy.model.Order;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO {

    // 1. Ambil Data Header Order (Untuk Invoice/Struk)
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

    // 2. Ambil Detail Barang (Untuk Invoice/Struk)
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
                
                CartItem item = new CartItem(0, m, rs.getInt("quantity"));
                list.add(item);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // --- FITUR ADMIN PANEL ---
    
    // 3. Ambil List Transaksi untuk Admin (Fix Status)
    public List<Order> getOrdersByPeriod(String period) {
        List<Order> list = new ArrayList<>();
        
        // Query Join User + Ambil Status
        String sql = "SELECT o.id, u.username, o.total_price, o.payment_method, o.order_date, o.status " + 
                     "FROM orders o JOIN users u ON o.user_id = u.id ";
        
        if ("today".equals(period)) {
            sql += "WHERE DATE(o.order_date) = CURDATE() ";
        } else if ("week".equals(period)) {
            sql += "WHERE YEARWEEK(o.order_date, 1) = YEARWEEK(CURDATE(), 1) ";
        } else if ("month".equals(period)) {
            sql += "WHERE MONTH(o.order_date) = MONTH(CURDATE()) AND YEAR(o.order_date) = YEAR(CURDATE()) ";
        }
        
        sql += "ORDER BY o.order_date DESC"; 

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Order o = new Order();
                o.setId(rs.getInt("id"));
                o.setUsername(rs.getString("username"));
                o.setTotal(rs.getDouble("total_price"));
                o.setMethod(rs.getString("payment_method"));
                o.setDate(rs.getTimestamp("order_date"));
                
                // PENTING: Set Status biar tombol Admin muncul
                o.setStatus(rs.getString("status")); 
                
                list.add(o);
            }
        } catch (Exception e) { 
            System.out.println("ERROR DAO: " + e.getMessage());
            e.printStackTrace(); 
        }
        return list;
    }

    // 4. Hitung Total Pendapatan
    // 2. Hitung Total Pendapatan Sesuai Filter (REVISI LOGIC)
public double getRevenueByPeriod(String period) {
    double total = 0;
    
    // UBAH LOGIC: Hitung yang statusnya PAID, PROCESSING, atau COMPLETED. 
    // Jangan hitung yang REJECTED atau CANCELLED.
    String sql = "SELECT SUM(total_price) FROM orders WHERE status IN ('PAID', 'PROCESSING', 'COMPLETED') "; 
    
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
    
    // 5. Update Status Pesanan (Admin Action)
    public boolean updateOrderStatus(int orderId, String newStatus) {
        boolean rowUpdated = false;
        String sql = "UPDATE orders SET status = ? WHERE id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, newStatus);
            statement.setInt(2, orderId);
            rowUpdated = statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rowUpdated;
    }

    // --- FITUR USER PANEL (BARU) ---

    // 6. Ambil Riwayat Pesanan User Tertentu
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY order_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setId(rs.getInt("id"));
                    // Username tidak perlu diset untuk view history sendiri
                    o.setTotal(rs.getDouble("total_price"));
                    o.setMethod(rs.getString("payment_method"));
                    o.setDate(rs.getTimestamp("order_date"));
                    
                    // PENTING: Ambil status biar user tau pesanan diterima/ditolak
                    o.setStatus(rs.getString("status")); 

                    list.add(o);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}