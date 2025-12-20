package com.makancuy.model;

import java.sql.Timestamp;

public class Order {
    private int id;
    private String username; // Kita ambil nama user, bukan ID doang
    private double total;
    private String method;
    private Timestamp date;

    public Order(int id, String username, double total, String method, Timestamp date) {
        this.id = id;
        this.username = username;
        this.total = total;
        this.method = method;
        this.date = date;
    }

    // Getter
    public int getId() { return id; }
    public String getUsername() { return username; }
    public double getTotal() { return total; }
    public String getMethod() { return method; }
    public Timestamp getDate() { return date; }
}