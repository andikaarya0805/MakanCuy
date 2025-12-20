package com.makancuy.controller;

import com.makancuy.dao.MenuDAO;
import com.makancuy.model.MenuItem;
import com.makancuy.model.Order;
import com.makancuy.dao.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin")
public class Admin extends HttpServlet {

    private MenuDAO menuDAO;

    @Override
    public void init() {
        menuDAO = new MenuDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Proteksi Login (Gunakan "user")
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // 2. Ambil parameter aksi dan ID
        String action = req.getParameter("action");
        String idParam = req.getParameter("id");

        // --- LOGIC HAPUS MENU (Request GET dari Link) ---
        if ("delete".equals(action) && idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                menuDAO.deleteMenu(id); // Pastikan method ini ada di MenuDAO
                resp.sendRedirect("admin?msg=deleted");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("admin?error=delete_failed");
                return;
            }
        }

        // --- LOGIC TAMPIL DATA DASHBOARD ---
        // Cek Filter Periode (Default: "all")
        String filter = req.getParameter("filter");
        if (filter == null) filter = "all";

        OrderDAO orderDAO = new OrderDAO();

        // Ambil semua data yang dibutuhin JSP
        List<MenuItem> menus = menuDAO.getAllMenus();
        double revenue = orderDAO.getRevenueByPeriod(filter);
        List<Order> salesReport = orderDAO.getOrdersByPeriod(filter);

        // Kirim data ke JSP
        req.setAttribute("adminMenu", menus);
        req.setAttribute("totalSales", revenue);
        req.setAttribute("salesReport", salesReport);
        req.setAttribute("currentFilter", filter);

        req.getRequestDispatcher("admin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Proteksi Login (Samakan jadi "user")
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // --- LOGIC TAMBAH MENU (Request POST dari Form) ---
        try {
            String name = req.getParameter("name");
            String desc = req.getParameter("description");
            double price = Double.parseDouble(req.getParameter("price"));
            String image = req.getParameter("image");
            String cat = req.getParameter("category");

            MenuItem newItem = new MenuItem(0, name, desc, price, image, cat);
            menuDAO.addMenu(newItem);
            
            resp.sendRedirect("admin?msg=added");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("admin?error=input");
        }
    }
}