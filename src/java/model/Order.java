package com.makancuy.model;

import java.sql.Timestamp;

public class Order {
    private int id;
    private String username; 
    private double total;
    private String method;
    private Timestamp date;
    
    // 1. TAMBAH VARIABLE INI
    private String status; 

    // Constructor Kosong (Wajib ada biar fleksibel)
    public Order() {}

    // Constructor Lengkap (Update tambah status)
    public Order(int id, String username, double total, String method, Timestamp date, String status) {
        this.id = id;
        this.username = username;
        this.total = total;
        this.method = method;
        this.date = date;
        this.status = status; // <--- Assign di sini
    }

    // Getter Lama
    public int getId() { return id; }
    public String getUsername() { return username; }
    public double getTotal() { return total; }
    public String getMethod() { return method; }
    public Timestamp getDate() { return date; }

    // 2. TAMBAH GETTER & SETTER STATUS (PENTING!)
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    // 3. Tambah Setter lain (Biar DAO kamu gak error kalau pake setter manual)
    public void setId(int id) { this.id = id; }
    public void setUsername(String username) { this.username = username; }
    public void setTotal(double total) { this.total = total; }
    public void setMethod(String method) { this.method = method; }
    public void setDate(Timestamp date) { this.date = date; }
}