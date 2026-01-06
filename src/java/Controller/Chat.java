package com.makancuy.controller;

import com.google.gson.Gson;
import com.makancuy.dao.ChatDAO;
import com.makancuy.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/chat")
public class Chat extends HttpServlet {

    private ChatDAO chatDAO;

    @Override
    public void init() {
        chatDAO = new ChatDAO();
    }

    // HANDLE REQUEST DATA (GET)
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        // 1. ADMIN: Minta Daftar User buat Sidebar
        if ("list_users".equals(action)) {
            List<Map<String, String>> users = chatDAO.getChatUsers();
            resp.getWriter().write(new Gson().toJson(users));
            return;
        }

        // 2. USER/ADMIN: Minta Isi Pesan
        if ("get_messages".equals(action)) {
            int userId = 0;
            
            // Kalau Admin yang minta, dia pasti bawa parameter ?user_id=...
            if (req.getParameter("user_id") != null) {
                userId = Integer.parseInt(req.getParameter("user_id"));
            } else {
                // Kalau User yang minta, ambil ID dari session dia sendiri
                User user = (User) req.getSession().getAttribute("user");
                if (user != null) userId = user.getId();
            }

            if (userId > 0) {
                List<Map<String, String>> msgs = chatDAO.getMessages(userId);
                resp.getWriter().write(new Gson().toJson(msgs));
            } else {
                resp.getWriter().write("[]");
            }
        }
    }

    // HANDLE KIRIM PESAN (POST)
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String message = req.getParameter("message");
        User user = (User) req.getSession().getAttribute("user");

        if (user == null || message == null || message.trim().isEmpty()) return;

        if ("send".equals(action)) {
            if ("admin".equals(user.getRole())) {
                // ADMIN KIRIM -> Butuh target_id (User mana yang dikirimin)
                String targetIdParam = req.getParameter("target_id");
                if (targetIdParam != null) {
                    int targetId = Integer.parseInt(targetIdParam);
                    chatDAO.sendMessage(targetId, "admin", message);
                }
            } else {
                // USER KIRIM -> Kirim ke diri sendiri (nanti dibaca admin)
                chatDAO.sendMessage(user.getId(), "user", message);
            }
            resp.getWriter().write("OK");
        }
    }
}