package com.makancuy.api;

import com.makancuy.dao.OrderDAO;
import com.makancuy.model.Order;
import com.makancuy.model.User;
import com.google.gson.Gson; // Pastikan library Gson ada
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/my-history")
public class UserHistoryAPI extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Cek Login (Keamanan)
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // Error 401
            return;
        }

        // 2. Ambil Data Order Milik User Ini
        OrderDAO dao = new OrderDAO();
        List<Order> myOrders = dao.getOrdersByUserId(user.getId());

        // 3. Format ke JSON
        List<Map<String, Object>> jsonList = new ArrayList<>();
        SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, HH:mm");

        for (Order o : myOrders) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", o.getId());
            map.put("date", sdf.format(o.getDate()));
            map.put("method", o.getMethod());
            map.put("total", o.getTotal());
            map.put("status", o.getStatus()); // <--- PENTING BUAT NOTIF

            jsonList.add(map);
        }

        String json = new Gson().toJson(jsonList);

        // 4. Kirim Response
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(json);
    }
}