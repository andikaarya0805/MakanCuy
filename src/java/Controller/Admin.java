package com.makancuy.controller;

import com.makancuy.dao.MenuDAO;
import com.makancuy.model.MenuItem;
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
        
        // DEBUG: Cek apakah Servlet dipanggil
        System.out.println("=== ADMIN SERVLET: MASUK ===");
        
        // 1. CEK LOGIN
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            System.out.println("DEBUG: User belum login, tendang ke login.jsp");
            resp.sendRedirect("login.jsp");
            return;
        }
        
        // 2. LOGIC HAPUS
        String action = req.getParameter("action");
        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                menuDAO.deleteMenu(id);
                System.out.println("DEBUG: Hapus menu ID " + id);
            } catch (Exception e) { e.printStackTrace(); }
            resp.sendRedirect("admin");
            return;
        }
// 2. Ambil Data Menu (Buat tabel bawah)
        MenuDAO dao = new MenuDAO();
        List<MenuItem> menus = dao.getAllMenus();
        
        // 3. AMBIL TOTAL PENDAPATAN (YANG BARU)
        double totalSales = dao.getTotalPendapatan(); // Panggil fungsi baru tadi

        // 4. Kirim ke JSP
        req.setAttribute("adminMenu", menus);
        req.setAttribute("totalSales", totalSales); // Kirim variabel sales
        
        req.getRequestDispatcher("admin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Cek Login
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("adminUser") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // Logic Tambah
        try {
            String name = req.getParameter("name");
            String desc = req.getParameter("description");
            double price = Double.parseDouble(req.getParameter("price"));
            String image = req.getParameter("image");
            String cat = req.getParameter("category");

            MenuItem newItem = new MenuItem(0, name, desc, price, image, cat);
            menuDAO.addMenu(newItem);
            System.out.println("DEBUG: Tambah menu baru sukses: " + name);
            
            resp.sendRedirect("admin");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect("admin?error=input");
        }
    }
}