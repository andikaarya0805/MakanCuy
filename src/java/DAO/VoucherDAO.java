package com.makancuy.dao;

import util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class VoucherDAO {

    // Fungsi Cek Kode Voucher
    // Return angka diskon (misal 10), kalau gak ketemu return 0
    public int checkVoucher(String code) {
        String sql = "SELECT discount_percent FROM vouchers WHERE code = ? AND is_active = 1";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, code);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("discount_percent");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0; // 0 artinya kode salah / gak ada
    }
}