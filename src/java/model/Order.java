package com.makancuy.model;

import java.sql.Timestamp;

public class Order {
    private int id;
    private String username; 
    private double total;
    private String method;
    private Timestamp date;
    private String status; 
    
    // --- TAMBAHAN BARU ---
    private String notes; 

    // Constructor Kosong
    public Order() {}

    // Constructor Lengkap
    public Order(int id, String username, double total, String method, Timestamp date, String status, String notes) {
        this.id = id;
        this.username = username;
        this.total = total;
        this.method = method;
        this.date = date;
        this.status = status;
        this.notes = notes;
    }

    // --- GETTER & SETTER ---
    
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public double getTotal() { return total; }
    public void setTotal(double total) { this.total = total; }

    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }

    public Timestamp getDate() { return date; }
    public void setDate(Timestamp date) { this.date = date; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    // --- GETTER SETTER NOTES (PENTING) ---
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}