package com.makancuy.dao;

import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatDAO {

    // 1. Kirim Pesan (Aman, gak perlu diubah)
    public void sendMessage(int userId, String sender, String message) {
        String sql = "INSERT INTO chat_messages (user_id, sender, message) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, sender); 
            ps.setString(3, message);
            ps.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // 2. Ambil Riwayat Pesan (Aman, gak perlu diubah)
    public List<Map<String, String>> getMessages(int userId) {
        List<Map<String, String>> list = new ArrayList<>();
        String sql = "SELECT sender, message, created_at FROM chat_messages WHERE user_id = ? ORDER BY created_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("sender", rs.getString("sender"));
                map.put("message", rs.getString("message"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // 3. FIX ERROR DISINI: Ambil Daftar User
    public List<Map<String, String>> getChatUsers() {
        List<Map<String, String>> list = new ArrayList<>();
        
        // QUERY UPDATE: Pake GROUP BY user_id dan urutkan berdasarkan chat TERAKHIR (MAX id)
        String sql = "SELECT c.user_id, u.username, MAX(c.id) as latest_msg_id " +
                     "FROM chat_messages c " +
                     "JOIN users u ON c.user_id = u.id " +
                     "GROUP BY c.user_id, u.username " +
                     "ORDER BY latest_msg_id DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("id", String.valueOf(rs.getInt("user_id")));
                map.put("username", rs.getString("username"));
                list.add(map);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}