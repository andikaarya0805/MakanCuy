package com.makancuy.controller;

import com.makancuy.dao.UserDAO;
import com.makancuy.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/auth")
public class Auth extends HttpServlet {

    // Handle Login (POST)
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String u = req.getParameter("username");
        String p = req.getParameter("password");
        
        UserDAO dao = new UserDAO();
        
        // Panggil method login baru yang mengembalikan Objek User
        User user = dao.login(u, p);
        
        if (user != null) {
            // --- LOGIN SUKSES ---
            HttpSession session = req.getSession();
            
            // 1. Simpan OBJECT USER LENGKAP (PENTING BUAT CART!)
            // CartServlet nanti akan panggil: ((User) session.getAttribute("user")).getId()
            session.setAttribute("user", user); 

            // 2. Simpan "adminUser" juga (Khusus biar AdminServlet lama gak error)
            if ("admin".equals(user.getRole())) {
                session.setAttribute("adminUser", user.getUsername());
            }

            // 3. Redirect sesuai ROLE
            if ("admin".equals(user.getRole())) {
                resp.sendRedirect("admin"); // Admin masuk Dashboard
            } else {
                resp.sendRedirect(""); // Customer masuk Halaman Depan
            }
            
        } else {
            // --- LOGIN GAGAL ---
            resp.sendRedirect("login.jsp?error=true");
        }
    }

    
    // Handle Logout (GET)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate(); // Hapus semua tiket (user & adminUser hilang)
        }
        resp.sendRedirect("login.jsp");
    }
}