package com.polycoffee.dao;

import com.polycoffee.entity.User;
import com.polycoffee.util.JdbcUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO - Thao tác CSDL bảng users
 */
public class UserDAO {

    public User findByEmailAndPassword(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ? AND active = 1";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);
            rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return null;
    }

    public User findById(int id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return null;
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) return map(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return null;
    }

    public List<User> findAllStaff() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = 'staff' ORDER BY id";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            rs  = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return list;
    }

    public List<User> findAll() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY role, id";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            rs  = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return list;
    }

    public boolean insert(User user) {
        // Check email unique
        if (findByEmail(user.getEmail()) != null) return false;
        String sql = "INSERT INTO users (email, password, full_name, phone, role, active) VALUES (?, ?, ?, ?, ?, ?)";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getRole());
            ps.setBoolean(6, user.isActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    public boolean update(User user) {
        String sql = "UPDATE users SET full_name=?, phone=?, role=?, active=? WHERE id=?";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getRole());
            ps.setBoolean(4, user.isActive());
            ps.setInt(5, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        String sql = "UPDATE users SET password=? WHERE id=? AND password=?";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setString(1, newPassword);
            ps.setInt(2, userId);
            ps.setString(3, oldPassword);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    public boolean toggleActive(int id) {
        String sql = "UPDATE users SET active = ~active WHERE id = ?";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    private User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setFullName(rs.getString("full_name"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));
        u.setActive(rs.getBoolean("active"));
        return u;
    }
    public boolean existsByPhone(String phone, int excludeId) {
        if (phone == null || phone.trim().isEmpty()) return false;
        String sql = "SELECT COUNT(*) FROM users WHERE phone = ? AND id != ?";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setString(1, phone.trim());
            ps.setInt(2, excludeId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return false;
    }
}
