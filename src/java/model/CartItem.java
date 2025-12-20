package com.makancuy.model;

public class CartItem {
    private int id; // ID Cart
    private MenuItem menu; // Objek Menu (biar bisa ambil nama/gambar)
    private int quantity;

    public CartItem(int id, MenuItem menu, int quantity) {
        this.id = id;
        this.menu = menu;
        this.quantity = quantity;
    }

    // Getter Setter standar
    public int getId() { return id; }
    public MenuItem getMenu() { return menu; }
    public int getQuantity() { return quantity; }
}