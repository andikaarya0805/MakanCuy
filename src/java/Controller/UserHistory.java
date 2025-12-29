package com.makancuy.controller;

import com.makancuy.dao.OrderDAO;
import com.makancuy.model.Order;
import com.makancuy.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/history")
public class UserHistory extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Cek User Login
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // 2. Ambil Data Pesanan User Tersebut
        OrderDAO dao = new OrderDAO();
            List<Order> myOrders = dao.getOrdersByUserId(user.getId());

        // 3. Kirim ke JSP
        req.setAttribute("myOrders", myOrders);
        req.getRequestDispatcher("history.jsp").forward(req, resp);
    }
}