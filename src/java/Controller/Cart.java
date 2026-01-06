package com.makancuy.controller;

import com.google.gson.Gson;
import com.makancuy.dao.CartDAO;
import com.makancuy.model.CartItem;
import com.makancuy.model.User;
import com.makancuy.dao.VoucherDAO;
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
            if ("json".equals(req.getParameter("mode"))) {
                resp.sendError(401, "Need Login");
            } else {
                resp.sendRedirect("login.jsp?error=need_login");
            }
            return;
        }

        User user = (User) session.getAttribute("user");
        int userId = user.getId();
        String action = req.getParameter("action");

        // --- 2. FITUR LIHAT KERANJANG (JSON) ---
        if ("view".equals(action)) {
            List<CartItem> items = cartDAO.getCartItems(userId);
            
            double grandTotal = 0;
            for (CartItem item : items) {
                grandTotal += (item.getMenu().getPrice() * item.getQuantity());
            }

            Gson gson = new Gson();
            String jsonItems = gson.toJson(items);
            String jsonResponse = "{\"items\": " + jsonItems + ", \"total\": " + grandTotal + "}";

            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(jsonResponse);
            return;
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
            return;
        }

        // --- 4. FITUR TAMBAH KERANJANG (ADD) ---
        if ("add".equals(action)) {
            try {
                int menuId = Integer.parseInt(req.getParameter("id"));
                cartDAO.addToCart(userId, menuId);
                resp.sendRedirect("./?status=added");
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("./?status=error");
            }
            return;
        }
        
        // --- 5. FITUR UPDATE CATATAN (FIXED: PAKE DAO) ---
        else if ("update_note".equals(action)) {
            try {
                int menuId = Integer.parseInt(req.getParameter("id"));
                String notes = req.getParameter("notes");
                
                // Panggil DAO buat simpan ke database
                cartDAO.updateNote(userId, menuId, notes);
                
                resp.getWriter().write("OK");
            } catch (Exception e) {
                e.printStackTrace();
            }
            return;
        }
        
        // --- 6. FITUR CEK VOUCHER (TARUH DI BAGIAN PALING BAWAH doGet) ---
        else if ("check_voucher".equals(action)) {
            String code = req.getParameter("code");
            
            VoucherDAO voucherDAO = new VoucherDAO();
            int discount = voucherDAO.checkVoucher(code);
            
            // Kirim balikan ke JS: {"discount": 20} atau {"discount": 0}
            resp.setContentType("application/json");
            resp.getWriter().write("{\"discount\": " + discount + "}");
            return;
        }
    }
}