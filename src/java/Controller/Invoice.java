package com.makancuy.controller;

import com.makancuy.dao.OrderDAO;
import com.makancuy.model.CartItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/invoice")
public class Invoice extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Ambil ID dari URL (misal: invoice?id=5)
        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendRedirect("./");
            return;
        }

        int orderId = Integer.parseInt(idStr);
        OrderDAO dao = new OrderDAO();
        
        // 1. Ambil Header
        String[] header = dao.getOrderHeader(orderId);
        
        // 2. Ambil Barang-barangnya
        List<CartItem> details = dao.getOrderDetails(orderId);
        
        // 3. Kirim ke JSP
        req.setAttribute("orderId", orderId);
        req.setAttribute("orderDate", header[0]);
        req.setAttribute("orderTotal", header[1]);
        req.setAttribute("paymentMethod", header[2]);
        req.setAttribute("orderItems", details);
        
        req.getRequestDispatcher("invoice.jsp").forward(req, resp);
    }
}