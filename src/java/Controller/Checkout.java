package com.makancuy.controller;

import com.makancuy.dao.CartDAO;
import com.makancuy.dao.OrderDAO;
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

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout-process"})
public class Checkout extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        // 1. Cek Login
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // 2. Ambil Cart Data
        CartDAO cartDAO = new CartDAO();
        OrderDAO orderDAO = new OrderDAO();

        // PENTING: getCartItems akan mengambil NOTES dari database
        List<CartItem> items = cartDAO.getCartItems(user.getId());

        if (items == null || items.isEmpty()) {
            resp.sendRedirect("index.jsp?error=empty_cart");
            return;
        }

        // 3. Ambil Payment Method dari JSP
        String paymentMethod = req.getParameter("paymentMethod");
        if (paymentMethod == null || paymentMethod.isEmpty()) {
            paymentMethod = "CASH"; // Default kalau null
        }

        // 4. Proses Checkout
        boolean success = orderDAO.checkout(user.getId(), items, paymentMethod);

        if (success) {
            // Sukses -> Redirect ke History
            resp.sendRedirect("history?status=success");
        } else {
            // Gagal -> Balik ke Checkout dengan error
            resp.sendRedirect("Checkout.jsp?error=checkout_failed");
        }
    }
}