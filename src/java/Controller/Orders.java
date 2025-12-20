package com.makancuy.controller;

import com.makancuy.dao.CartDAO;
import com.makancuy.model.CartItem;
import com.makancuy.model.User;
import util.DBConnection; // Perbaikan Import
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
import java.sql.Statement;
import java.util.List;

@WebServlet("/processOrder")
public class Orders extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (User) session.getAttribute("user");
        
        // Ambil Metode Pembayaran dari Form Checkout
        String paymentMethod = req.getParameter("paymentMethod");
        if (paymentMethod == null) paymentMethod = "COD"; // Default

        CartDAO cartDAO = new CartDAO();
        List<CartItem> items = cartDAO.getCartItems(user.getId());

        if (items.isEmpty()) {
            resp.sendRedirect("./"); // Balik ke root
            return;
        }

        double total = 0;
        for (CartItem item : items) total += (item.getMenu().getPrice() * item.getQuantity());

        try (Connection conn = DBConnection.getConnection()) {
            
            // 1. Simpan Header Order
            String sqlOrder = "INSERT INTO orders (user_id, total_price, status, payment_method) VALUES (?, ?, 'PAID', ?)";
            PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, user.getId());
            psOrder.setDouble(2, total);
            psOrder.setString(3, paymentMethod);
            psOrder.executeUpdate();
            
            // Ambil ID Order (PENTING BUAT INVOICE)
            ResultSet rsKey = psOrder.getGeneratedKeys();
            int orderId = 0;
            if (rsKey.next()) orderId = rsKey.getInt(1);

            // 2. Simpan Detail Items
            String sqlItem = "INSERT INTO order_items (order_id, menu_id, price_at_purchase, quantity) VALUES (?, ?, ?, ?)";
            PreparedStatement psItem = conn.prepareStatement(sqlItem);
            
            for (CartItem item : items) {
                psItem.setInt(1, orderId);
                psItem.setInt(2, item.getMenu().getId());
                psItem.setDouble(3, item.getMenu().getPrice());
                psItem.setInt(4, item.getQuantity());
                psItem.addBatch(); 
            }
            psItem.executeBatch(); 

            // 3. Kosongkan Keranjang
            cartDAO.clearCart(user.getId());

            // --- SUKSES! REDIRECT KE INVOICE ---
            // Kirim ID Order ke InvoiceServlet biar bisa dicetak
            resp.sendRedirect("invoice?id=" + orderId);

        } catch (Exception e) {
            e.printStackTrace();
            // Kalau error, balik ke home kasih tau gagal
            resp.sendRedirect("./?status=order_failed");
        }
    }
}