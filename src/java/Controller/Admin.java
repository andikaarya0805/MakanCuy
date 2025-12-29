package com.makancuy.controller;

import com.makancuy.dao.MenuDAO;
import com.makancuy.dao.OrderDAO; // Pastikan import ini ada
import com.makancuy.model.MenuItem;
import com.makancuy.model.Order;
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
    private OrderDAO orderDAO; // Tambahkan ini

    @Override
    public void init() {
        menuDAO = new MenuDAO();
        orderDAO = new OrderDAO(); // Inisialisasi di sini biar rapi
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Proteksi Login
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // 2. Ambil parameter aksi dan ID
        String action = req.getParameter("action");
        String idParam = req.getParameter("id");

        // --- LOGIC HAPUS MENU ---
        if ("delete".equals(action) && idParam != null) {
            try {
                int id = Integer.parseInt(idParam);
                menuDAO.deleteMenu(id);
                resp.sendRedirect("admin?msg=deleted");
                return;
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("admin?error=delete_failed");
                return;
            }
        }

        // --- LOGIC TAMPIL DATA DASHBOARD ---
        String filter = req.getParameter("filter");
        if (filter == null) filter = "all";

        List<MenuItem> menus = menuDAO.getAllMenus();
        double revenue = orderDAO.getRevenueByPeriod(filter);
        List<Order> salesReport = orderDAO.getOrdersByPeriod(filter); // Logic Order List

        req.setAttribute("adminMenu", menus);
        req.setAttribute("totalSales", revenue);
        req.setAttribute("salesReport", salesReport);
        req.setAttribute("currentFilter", filter);

        req.getRequestDispatcher("admin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Proteksi Login
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        // 2. Cek Action: Apakah ini "Tambah Menu" atau "Update Order"?
        String action = req.getParameter("action");
        
        // --- LOGIC UPDATE STATUS ORDER (Confirm/Reject) ---
        // Kita cek action-nya apakah mengandung kata kunci order
        if ("confirm".equals(action) || "reject".equals(action) || "complete".equals(action)) {
            try {
                int orderId = Integer.parseInt(req.getParameter("id"));
                String newStatus = "";

                if ("confirm".equals(action)) {
                    newStatus = "PROCESSING";
                } else if ("reject".equals(action)) {
                    newStatus = "REJECTED";
                } else if ("complete".equals(action)) {
                    newStatus = "COMPLETED";
                }

                // Update ke Database
                orderDAO.updateOrderStatus(orderId, newStatus);
                
                // Balik ke admin panel
                resp.sendRedirect("admin?msg=StatusUpdated");
            
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("admin?error=update_failed");
            }
        } 
        
        // --- LOGIC TAMBAH MENU (Default jika action null atau add_menu) ---
        else { 
            try {
                // Pastikan form tambah menu punya <input type="hidden" name="action" value="add_menu"> 
                // atau biarkan logic ini jalan sebagai default kalau action kosong.
                
                String name = req.getParameter("name");
                // Validasi sederhana biar gak error kalau form kosong
                if(name != null) {
                    String desc = req.getParameter("description");
                    double price = Double.parseDouble(req.getParameter("price"));
                    String image = req.getParameter("image");
                    String cat = req.getParameter("category");
    
                    MenuItem newItem = new MenuItem(0, name, desc, price, image, cat);
                    menuDAO.addMenu(newItem);
                    
                    resp.sendRedirect("admin?msg=added");
                } else {
                    // Kalau masuk sini tapi gak ada parameter name, mungkin error
                    resp.sendRedirect("admin?error=unknown_action");
                }
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendRedirect("admin?error=input");
            }
        }
    }
}