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
    // UPDATE: Ambil kolom 'notes' juga biar muncul di struk
    public List<CartItem> getOrderDetails(int orderId) {
        List<CartItem> list = new ArrayList<>();
        // Tambahkan oi.notes ke dalam query
        String sql = "SELECT m.name, m.price, oi.quantity, oi.notes " +
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
                // Set notes ke objek CartItem
                item.setNotes(rs.getString("notes")); 
                list.add(item);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // --- FITUR ADMIN PANEL ---
    
    // 3. Ambil List Transaksi untuk Admin (Fix Status & Notes)
    public List<Order> getOrdersByPeriod(String period) {
        List<Order> list = new ArrayList<>();
        
        // UPDATE QUERY: Tambahkan GROUP_CONCAT untuk menggabungkan notes dari semua item dalam satu order
        // Notes digabung jadi satu string, dipisah koma.
        String sql = "SELECT o.id, u.username, o.total_price, o.payment_method, o.order_date, o.status, " + 
                     "GROUP_CONCAT(IFNULL(oi.notes, '') SEPARATOR ', ') as all_notes " +
                     "FROM orders o " +
                     "JOIN users u ON o.user_id = u.id " +
                     "LEFT JOIN order_items oi ON o.id = oi.order_id "; // Join ke items buat ambil notes
        
        String condition = "";
        if ("today".equals(period)) {
            condition = "WHERE DATE(o.order_date) = CURDATE() ";
        } else if ("week".equals(period)) {
            condition = "WHERE YEARWEEK(o.order_date, 1) = YEARWEEK(CURDATE(), 1) ";
        } else if ("month".equals(period)) {
            condition = "WHERE MONTH(o.order_date) = MONTH(CURDATE()) AND YEAR(o.order_date) = YEAR(CURDATE()) ";
        }
        
        sql += condition + "GROUP BY o.id ORDER BY o.order_date DESC"; 

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
                o.setStatus(rs.getString("status")); 
                
                // Logic bersihin notes (hapus koma kosong berlebih)
                String rawNotes = rs.getString("all_notes");
                String cleanNotes = "";
                if (rawNotes != null && !rawNotes.matches("^[,\\s]*$")) {
                     cleanNotes = rawNotes.replaceAll("^[,\\s]+", "").replaceAll("[,\\s]+$", "");
                }
                o.setNotes(cleanNotes); // Simpan notes ke object Order (pastikan Model Order punya field notes)
                
                list.add(o);
            }
        } catch (Exception e) { 
            System.out.println("ERROR DAO: " + e.getMessage());
            e.printStackTrace(); 
        }
        return list;
    }

    // 4. Hitung Total Pendapatan
    public double getRevenueByPeriod(String period) {
        double total = 0;
        
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

    // 6. Ambil Riwayat Pesanan User Tertentu (Plus Notes)
    public List<Order> getOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        // UPDATE QUERY: Tambahkan GROUP_CONCAT notes
        String sql = "SELECT o.*, GROUP_CONCAT(IFNULL(oi.notes, '') SEPARATOR ', ') as all_notes " +
                     "FROM orders o " +
                     "LEFT JOIN order_items oi ON o.id = oi.order_id " +
                     "WHERE o.user_id = ? " +
                     "GROUP BY o.id " +
                     "ORDER BY o.order_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
             
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order();
                    o.setId(rs.getInt("id"));
                    o.setTotal(rs.getDouble("total_price"));
                    o.setMethod(rs.getString("payment_method"));
                    o.setDate(rs.getTimestamp("order_date"));
                    o.setStatus(rs.getString("status")); 
                    
                    // Logic bersihin notes sama kayak admin
                    String rawNotes = rs.getString("all_notes");
                    String cleanNotes = "";
                    if (rawNotes != null && !rawNotes.matches("^[,\\s]*$")) {
                         cleanNotes = rawNotes.replaceAll("^[,\\s]+", "").replaceAll("[,\\s]+$", "");
                    }
                    o.setNotes(cleanNotes);

                    list.add(o);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    // ---------------------------------------------------------
    // FITUR UTAMA: CHECKOUT (SIMPAN ORDER + NOTES)
    // ---------------------------------------------------------
    public boolean checkout(int userId, List<CartItem> cartItems, String paymentMethod) {
        boolean isSuccess = false;
        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psItems = null;
        PreparedStatement psClearCart = null;
        ResultSet rs = null;

        double grandTotal = 0;
        for (CartItem item : cartItems) {
            grandTotal += (item.getMenu().getPrice() * item.getQuantity());
        }

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); 

            // 1. INSERT ORDERS (Pastikan kolom total_price benar)
            String sqlOrder = "INSERT INTO orders (user_id, total_price, payment_method, status, order_date) VALUES (?, ?, ?, 'PAID', NOW())";
            psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, userId);
            psOrder.setDouble(2, grandTotal);
            psOrder.setString(3, paymentMethod);
            psOrder.executeUpdate();

            int orderId = 0;
            rs = psOrder.getGeneratedKeys();
            if (rs.next()) {
                orderId = rs.getInt(1);
            }

            // 2. INSERT ORDER_ITEMS (FIX NAMA KOLOM DISINI)
            // Ganti 'price' jadi 'price_at_purchase'
            String sqlItem = "INSERT INTO order_items (order_id, menu_id, quantity, price_at_purchase, notes) VALUES (?, ?, ?, ?, ?)";
            psItems = conn.prepareStatement(sqlItem);

            for (CartItem item : cartItems) {
                psItems.setInt(1, orderId);
                psItems.setInt(2, item.getMenu().getId());
                psItems.setInt(3, item.getQuantity());
                psItems.setDouble(4, item.getMenu().getPrice());
                psItems.setString(5, item.getNotes()); 
                
                psItems.addBatch();
            }
            psItems.executeBatch();

            // 3. HAPUS CART
            String sqlClear = "DELETE FROM cart WHERE user_id = ?";
            psClearCart = conn.prepareStatement(sqlClear);
            psClearCart.setInt(1, userId);
            psClearCart.executeUpdate();

            conn.commit();
            isSuccess = true;

        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("CHECKOUT ERROR: " + e.getMessage());
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) {}
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (psOrder != null) psOrder.close(); } catch (Exception e) {}
            try { if (psItems != null) psItems.close(); } catch (Exception e) {}
            try { if (psClearCart != null) psClearCart.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return isSuccess;
    }
}