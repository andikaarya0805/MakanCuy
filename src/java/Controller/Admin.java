package com.makancuy.controller;

import com.makancuy.dao.MenuDAO;
import com.makancuy.dao.OrderDAO;
import com.makancuy.model.MenuItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "AdminServlet", urlPatterns = {"/admin"})
public class Admin extends HttpServlet {

    private MenuDAO menuDAO;
    private OrderDAO orderDAO;

    @Override
    public void init() {
        menuDAO = new MenuDAO();
        orderDAO = new OrderDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Cek Login
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");

        // 2. Handle Hapus Menu
        if ("delete".equals(action)) {
            try {
                String idParam = req.getParameter("id");
                if (idParam != null) {
                    int id = Integer.parseInt(idParam);
                    menuDAO.deleteMenu(id);
                    resp.sendRedirect("admin?msg=deleted");
                }
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("admin?error=delete_failed");
            }
            return;
        }

        // 3. Load Data Halaman Admin
        // Data Order & Chart diambil via API (AdminStatsServlet) biar realtime & enteng.
        // Disini kita cukup siapin list menu buat tab "Manajemen Menu".
        List<MenuItem> menus = menuDAO.getAllMenus();
        req.setAttribute("adminMenu", menus);

        req.getRequestDispatcher("admin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Cek Login
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String action = req.getParameter("action");

        try {
            // --- A. UPDATE STATUS ORDER (Dari Dropdown/Tombol di Admin) ---
            // Frontend ngirim: action="update_status", id=123, status="PROCESSING"
            if ("update_status".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                String newStatus = req.getParameter("status"); // PROCESSING, DELIVERING, COMPLETED, REJECTED
                
                orderDAO.updateOrderStatus(id, newStatus);
                
                // Kita balikin status 200 OK biar JavaScript tau berhasil
                resp.setStatus(HttpServletResponse.SC_OK);
            } 
            
            // --- B. TAMBAH MENU BARU ---
            else if ("add_menu".equals(action)) {
                String name = req.getParameter("name");
                String desc = req.getParameter("description");
                double price = Double.parseDouble(req.getParameter("price"));
                String image = req.getParameter("image");
                String cat = req.getParameter("category");

                MenuItem newItem = new MenuItem(0, name, desc, price, image, cat);
                menuDAO.addMenu(newItem);

                resp.sendRedirect("admin?msg=added");
            }
            
            // --- C. FALLBACK ---
            else {
                resp.sendRedirect("admin");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("admin?error=action_failed");
        }
    }
}