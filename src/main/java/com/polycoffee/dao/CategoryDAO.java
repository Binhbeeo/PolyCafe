package com.polycoffee.dao;

import com.polycoffee.entity.Category;
import com.polycoffee.util.JdbcUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * CategoryDAO - Thao tác CSDL bảng categories
 */
public class CategoryDAO {

    // -------------------- CRUD --------------------

    public List<Category> findAll() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, name, active FROM categories ORDER BY id";
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

    public List<Category> findAllActive() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, name, active FROM categories WHERE active = 1 ORDER BY name";
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

    public Category findById(int id) {
        String sql = "SELECT id, name, active FROM categories WHERE id = ?";
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

    public boolean insert(Category category) {
        String sql = "INSERT INTO categories (name, active) VALUES (?, ?)";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setString(1, category.getName());
            ps.setBoolean(2, category.isActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    public boolean update(Category category) {
        String sql = "UPDATE categories SET name = ?, active = ? WHERE id = ?";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setString(1, category.getName());
            ps.setBoolean(2, category.isActive());
            ps.setInt(3, category.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    /**
     * Xóa loại đồ uống — chỉ được xóa khi loại chưa có đồ uống nào thuộc về.
     * Trả về: 1 = xóa thành công, 0 = không tìm thấy, -1 = còn đồ uống (không thể xóa)
     */
    public int delete(int id) {
        String sqlCheck = "SELECT COUNT(1) FROM drinks WHERE category_id = ?";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sqlCheck);
            ps.setInt(1, id);
            rs  = ps.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) return -1;
            JdbcUtil.close(rs, ps); rs = null;

            String sql = "DELETE FROM categories WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0 ? 1 : 0;
        } catch (SQLException e) { e.printStackTrace(); return 0; }
        finally { JdbcUtil.close(rs, ps, con); }
    }

    public boolean toggleActive(int id) {
        String sql = "UPDATE categories SET active = ~active WHERE id = ?";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    // -------------------- Mapping --------------------

    private Category map(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setId(rs.getInt("id"));
        c.setName(rs.getString("name"));
        c.setActive(rs.getBoolean("active"));
        return c;
    }
    public boolean existsByName(String name, int excludeId) {
        String sql = "SELECT COUNT(*) FROM categories WHERE LOWER(name) = LOWER(?) AND id != ?";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setInt(2, excludeId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return false;
    }
}
