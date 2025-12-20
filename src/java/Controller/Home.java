package com.makancuy.controller;

import com.makancuy.dao.MenuDAO;
import com.makancuy.model.MenuItem;
import com.google.gson.Gson; // Pastikan import ini ada
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

// URL Pattern "" artinya ini halaman utama
@WebServlet("")
public class Home extends HttpServlet { // Pastikan nama class sama dengan nama file (HomeServlet)

    private MenuDAO menuDAO;

    @Override
    public void init() {
        menuDAO = new MenuDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        // --- 1. FITUR AJAX JSON (PRIORITAS UTAMA) ---
        // Cek dulu, apakah request ini minta JSON?
        if ("json".equals(req.getParameter("mode"))) {
            
            // Ambil data terbaru
            List<MenuItem> menuList = menuDAO.getAllMenus();
            
            // Ubah List Java jadi JSON String pakai GSON
            String json = new Gson().toJson(menuList);
            
            // Kirim sebagai JSON ke browser
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(json);
            
            return; // STOP! Jangan lanjut ke bawah (JSP). Tugas selesai.
        }

        // --- 2. LOGIC BIASA (Load Halaman HTML/JSP) ---
        // Kalau kode sampai sini, berarti user TIDAK minta JSON, tapi minta halaman biasa.
        
        System.out.println("=== MULAI REQUEST HOMESERVLET (HTML) ===");
        
        List<MenuItem> menuList = menuDAO.getAllMenus();
        
        System.out.println("Jumlah data yang diambil dari DB: " + menuList.size());
        
        // Kirim data ke JSP
        req.setAttribute("genZMenu", menuList);
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}