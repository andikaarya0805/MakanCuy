package com.makancuy.dao;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.makancuy.model.CartItem;
import com.makancuy.model.MenuItem;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    // Fungsi Tambah ke Keranjang
    public boolean addToCart(int userId, int menuId) {
        String checkSql = "SELECT * FROM cart WHERE user_id = ? AND menu_id = ?";
        String updateSql = "UPDATE cart SET quantity = quantity + 1 WHERE user_id = ? AND menu_id = ?";
        String insertSql = "INSERT INTO cart (user_id, menu_id, quantity) VALUES (?, ?, 1)";

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Cek apakah barang udah ada di keranjang user ini?
            PreparedStatement psCheck = conn.prepareStatement(checkSql);
            psCheck.setInt(1, userId);
            psCheck.setInt(2, menuId);
            ResultSet rs = psCheck.executeQuery();

            if (rs.next()) {
                // Barang ada -> Update Jumlahnya (+1)
                PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                psUpdate.setInt(1, userId);
                psUpdate.setInt(2, menuId);
                return psUpdate.executeUpdate() > 0;
            } else {
                // Barang baru -> Insert Baru
                PreparedStatement psInsert = conn.prepareStatement(insertSql);
                psInsert.setInt(1, userId);
                psInsert.setInt(2, menuId);
                return psInsert.executeUpdate() > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 1. AMBIL SEMUA ISI KERANJANG USER
    public List<CartItem> getCartItems(int userId) {
        List<CartItem> list = new ArrayList<>();
        String sql = "SELECT c.id, c.quantity, m.id as menu_id, m.name, m.price, m.image_url, m.category " +
                     "FROM cart c JOIN menu m ON c.menu_id = m.id " +
                     "WHERE c.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                MenuItem menu = new MenuItem();
                menu.setId(rs.getInt("menu_id"));
                menu.setName(rs.getString("name"));
                menu.setPrice(rs.getDouble("price"));
                menu.setImageUrl(rs.getString("image_url"));
                
                list.add(new CartItem(rs.getInt("id"), menu, rs.getInt("quantity")));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 2. KOSONGKAN KERANJANG (Dipakai pas Checkout)
    public void clearCart(int userId) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("DELETE FROM cart WHERE user_id=?")) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }
    // FUNGSI UPDATE QUANTITY (+1 atau -1)
    public void updateQuantity(int userId, int menuId, int change) {
        String sqlCheck = "SELECT quantity FROM cart WHERE user_id = ? AND menu_id = ?";
        String sqlUpdate = "UPDATE cart SET quantity = quantity + ? WHERE user_id = ? AND menu_id = ?";
        String sqlDelete = "DELETE FROM cart WHERE user_id = ? AND menu_id = ?";

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Cek Quantity Sekarang
            PreparedStatement psCheck = conn.prepareStatement(sqlCheck);
            psCheck.setInt(1, userId);
            psCheck.setInt(2, menuId);
            ResultSet rs = psCheck.executeQuery();

            if (rs.next()) {
                int currentQty = rs.getInt("quantity");
                int newQty = currentQty + change;

                if (newQty <= 0) {
                    // Kalau hasil 0 atau minus, HAPUS barangnya
                    PreparedStatement psDel = conn.prepareStatement(sqlDelete);
                    psDel.setInt(1, userId);
                    psDel.setInt(2, menuId);
                    psDel.executeUpdate();
                } else {
                    // Kalau masih ada sisa, UPDATE jumlahnya
                    PreparedStatement psUp = conn.prepareStatement(sqlUpdate);
                    psUp.setInt(1, change); // +1 atau -1
                    psUp.setInt(2, userId);
                    psUp.setInt(3, menuId);
                    psUp.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}