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

    // Handle Login & Register (POST)
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        // 1. TANGKAP ACTION DULU (Penting!)
        // (Dari input hidden di form login/register)
        String action = req.getParameter("action");

        UserDAO dao = new UserDAO();

        // --- SKENARIO A: REGISTER ---
        if ("register".equals(action)) {
            String u = req.getParameter("username");
            String p = req.getParameter("password");

            // Panggil method register
            dao.registerUser(u, p);

            // Balik ke halaman login kasih notif sukses
            resp.sendRedirect("login.jsp?status=registered");
            return; // <--- STOP DISINI, JANGAN LANJUT KE LOGIN
        }

        // --- SKENARIO B: LOGIN (Default) ---
        // Kalau action bukan register, berarti dia mau login
        String u = req.getParameter("username");
        String p = req.getParameter("password");
        
        User user = dao.login(u, p);
        
        if (user != null) {
            // --- LOGIN SUKSES ---
            HttpSession session = req.getSession();
            
            // 1. Simpan OBJECT USER LENGKAP (PENTING BUAT CART!)
            session.setAttribute("user", user); 

            // 2. Simpan "adminUser" (Compatibility Mode)
            if ("admin".equals(user.getRole())) {
                session.setAttribute("adminUser", user.getUsername());
            }

            // 3. Redirect sesuai ROLE
            if ("admin".equals(user.getRole())) {
                resp.sendRedirect("admin"); // Admin -> Dashboard
            } else {
                resp.sendRedirect("./"); // Customer -> Halaman Utama
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
            session.invalidate(); // Hapus semua sesi
        }
        resp.sendRedirect("login.jsp");
    }
}