package com.makancuy.controller;

import com.makancuy.dao.OrderDAO;
import com.makancuy.model.Order;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/admin-stats")
public class AdminAPI extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String filter = req.getParameter("filter");
        if (filter == null) filter = "all";

        OrderDAO dao = new OrderDAO();
        double total = dao.getRevenueByPeriod(filter);
        List<Order> history = dao.getOrdersByPeriod(filter);

        // Format data agar ramah JavaScript
        List<Map<String, Object>> historyList = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("dd MMM HH:mm");

        for (Order o : history) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", o.getId());
            map.put("username", o.getUsername());
            map.put("total", o.getTotal()); // Pastikan di Model Order namanya getTotal() atau getTotalPrice()
            map.put("method", o.getMethod()); // Pastikan di Model Order namanya getMethod() atau getPaymentMethod()
            map.put("date", sdf.format(o.getDate())); 
            
            // --- INI YANG KURANG TADI ---
            // JavaScript butuh field "status" buat nentuin warna badge & tombol terima/tolak
            map.put("status", o.getStatus()); 
            // ----------------------------

            historyList.add(map);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("totalRevenue", total);
        data.put("history", historyList);

        String json = new Gson().toJson(data);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(json);
    }
}