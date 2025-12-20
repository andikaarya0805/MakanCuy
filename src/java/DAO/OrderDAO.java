package com.makancuy.dao;

import com.makancuy.model.CartItem;
import com.makancuy.model.MenuItem;
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
}