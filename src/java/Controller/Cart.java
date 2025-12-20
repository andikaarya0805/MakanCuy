package com.makancuy.controller;

import com.google.gson.Gson;
import com.makancuy.dao.CartDAO;
import com.makancuy.model.CartItem;
import com.makancuy.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/cart")
public class Cart extends HttpServlet {

    private CartDAO cartDAO;

    @Override
    public void init() {
        cartDAO = new CartDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        // --- 1. CEK LOGIN (SATPAM) ---
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            // Kalau request AJAX minta JSON
            if ("json".equals(req.getParameter("mode"))) {
                resp.sendError(401, "Need Login");
            } else {
                resp.sendRedirect("login.jsp?error=need_login");
            }
            return; // <--- WAJIB RETURN BIAR GAK LANJUT KE BAWAH
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();
        String action = req.getParameter("action");

        // --- 2. FITUR LIHAT KERANJANG (JSON) ---
        if ("view".equals(action)) {
            List<CartItem> items = cartDAO.getCartItems(userId);
            
            // Hitung Total
            double grandTotal = 0;
            for (CartItem item : items) {
                grandTotal += (item.getMenu().getPrice() * item.getQuantity());
            }

            // Kirim JSON
            Gson gson = new Gson();
            String jsonItems = gson.toJson(items);
            String jsonResponse = "{\"items\": " + jsonItems + ", \"total\": " + grandTotal + "}";

            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(jsonResponse);
            return; // <--- STOP DI SINI
        }

        // --- 3. FITUR UPDATE QUANTITY (+ / -) ---
        if ("update".equals(action)) {
            try {
                int menuId = Integer.parseInt(req.getParameter("id"));
                int qtyChange = Integer.parseInt(req.getParameter("qty")); 
                
                cartDAO.updateQuantity(userId, menuId, qtyChange);
                
                resp.setContentType("application/json");
                resp.getWriter().write("{\"status\":\"ok\"}");
            } catch (Exception e) {
                e.printStackTrace();
            }
            return; // <--- STOP DI SINI
        }

        // --- 4. FITUR TAMBAH KERANJANG (ADD) ---
        if ("add".equals(action)) {
            try {
                int menuId = Integer.parseInt(req.getParameter("id"));
                cartDAO.addToCart(userId, menuId);
                
                // Redirect ke ./ (Root) bukan index.jsp biar URL bersih
                resp.sendRedirect("./?status=added");
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("./?status=error");
            }
            return; // <--- INI YG BIKIN ERROR 500 KALAU LUPA DITULIS
        }
    }
}