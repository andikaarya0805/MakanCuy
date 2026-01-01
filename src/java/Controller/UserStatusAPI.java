package com.makancuy.controller;

import com.google.gson.Gson;
import com.makancuy.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;
import util.DBConnection;

@WebServlet("/api/user-status")
public class UserStatusAPI extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.getWriter().write("{}"); // Balikin kosong kalau gak login
            return;
        }

        User user = (User) session.getAttribute("user");
        Map<String, Object> result = new HashMap<>();

        try (Connection conn = DBConnection.getConnection()) {
            // Ambil 1 pesanan terakhir user ini
            String sql = "SELECT id, status FROM orders WHERE user_id = ? ORDER BY id DESC LIMIT 1";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, user.getId());
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                result.put("orderId", rs.getInt("id"));
                result.put("status", rs.getString("status"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        resp.getWriter().write(new Gson().toJson(result));
    }
}