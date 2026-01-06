package com.makancuy.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import util.DBConnection;

@WebServlet(name = "AdminAPI", urlPatterns = {"/api/admin-stats"})
public class AdminAPI extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String filter = request.getParameter("filter");
        if (filter == null) filter = "all";

        // 1. SESUAIKAN NAMA KOLOM TANGGAL (order_date)
        String colDate = "o.order_date"; 

        String dateCondition = "";
        switch (filter) {
            case "today":
                dateCondition = " AND DATE(" + colDate + ") = CURDATE()";
                break;
            case "week":
                dateCondition = " AND YEARWEEK(" + colDate + ", 1) = YEARWEEK(CURDATE(), 1)";
                break;
            case "month":
                dateCondition = " AND MONTH(" + colDate + ") = MONTH(CURDATE()) AND YEAR(" + colDate + ") = YEAR(CURDATE())";
                break;
            default: 
                dateCondition = ""; 
                break;
        }

        try (PrintWriter out = response.getWriter();
             Connection conn = DBConnection.getConnection()) {

            JsonObject jsonResponse = new JsonObject();
            JsonArray historyArray = new JsonArray();
            double totalRevenue = 0;

            // 2. UPDATE QUERY SQL (SESUAI STRUKTUR DB LU + TAMBAH NOTES)
            // Kita pake GROUP_CONCAT buat notes juga
            String sql = 
                "SELECT " +
                "  o.id, " +
                "  o.order_date, " + 
                "  u.username, " + 
                "  o.total_price, " +
                "  o.status, " +
                "  o.payment_method, " +
                "  GROUP_CONCAT(CONCAT(oi.quantity, 'x ', m.name) SEPARATOR ', ') as items_desc, " +
                "  GROUP_CONCAT(IFNULL(oi.notes, '') SEPARATOR ', ') as all_notes " + // <-- TAMBAHAN: Ambil notes
                "FROM orders o " +
                "LEFT JOIN users u ON o.user_id = u.id " +          
                "LEFT JOIN order_items oi ON o.id = oi.order_id " + 
                "LEFT JOIN menu m ON oi.menu_id = m.id " +          
                "WHERE 1=1 " + dateCondition + " " +
                "GROUP BY o.id " +
                "ORDER BY o.order_date DESC";
            
            System.out.println("DEBUG SQL: " + sql); 

            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                JsonObject order = new JsonObject();
                order.addProperty("id", rs.getInt("id"));
                
                try {
                    order.addProperty("date", rs.getTimestamp("order_date").toString());
                } catch (Exception e) {
                    order.addProperty("date", "-");
                }

                String user = rs.getString("username");
                order.addProperty("username", (user != null) ? user : "Unknown User");
                
                try {
                    order.addProperty("total", rs.getDouble("total_price")); 
                } catch (SQLException e) {
                    order.addProperty("total", 0);
                }
                
                order.addProperty("status", rs.getString("status"));
                order.addProperty("method", rs.getString("payment_method"));
                
                String items = rs.getString("items_desc");
                order.addProperty("itemsDesc", (items != null) ? items : "Detail kosong");

                // --- TAMBAHAN LOGIC NOTES ---
                String rawNotes = rs.getString("all_notes");
                String cleanNotes = "";
                if (rawNotes != null) {
                    // Bersihin koma ganda atau spasi kosong (misal: " , , pedes, ")
                    // Regex ini ngecek kalau isinya cuma koma/spasi doang -> anggep kosong
                    if (!rawNotes.matches("^[,\\s]*$")) {
                        // Kalau ada isinya, kita rapihin dikit (ilangin koma di awal/akhir)
                        cleanNotes = rawNotes.replaceAll("^[,\\s]+", "").replaceAll("[,\\s]+$", "");
                    }
                }
                order.addProperty("notes", cleanNotes);
                // ---------------------------

                historyArray.add(order);
                
                String status = rs.getString("status");
                if (!"REJECTED".equals(status) && !"PENDING".equals(status)) {
                    totalRevenue += order.get("total").getAsDouble();
                }
            }

            jsonResponse.addProperty("totalRevenue", totalRevenue);
            jsonResponse.add("history", historyArray);
            
            out.print(new Gson().toJson(jsonResponse));

        } catch (Exception e) {
            e.printStackTrace();
            JsonObject err = new JsonObject();
            err.addProperty("error", "Database Error: " + e.getMessage());
            response.getWriter().print(new Gson().toJson(err));
        }
    }
}   