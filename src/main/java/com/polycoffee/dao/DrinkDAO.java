package com.polycoffee.dao;

import com.polycoffee.entity.Drink;
import com.polycoffee.util.JdbcUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DrinkDAO - Thao tác CSDL bảng drinks
 */
public class DrinkDAO {

    // -------------------- CRUD --------------------

    public List<Drink> findAll() {
        List<Drink> list = new ArrayList<>();
        String sql = "SELECT d.id, d.category_id, d.name, d.price, d.image, d.description, d.active, c.name AS category_name " +
                     "FROM drinks d LEFT JOIN categories c ON d.category_id = c.id ORDER BY d.id";
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

    public List<Drink> findAllActive() {
        List<Drink> list = new ArrayList<>();
        String sql = "SELECT d.id, d.category_id, d.name, d.price, d.image, d.description, d.active, c.name AS category_name " +
                     "FROM drinks d LEFT JOIN categories c ON d.category_id = c.id WHERE d.active = 1 ORDER BY d.name";
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

    public List<Drink> findByCategory(int categoryId) {
        List<Drink> list = new ArrayList<>();
        String sql = "SELECT d.id, d.category_id, d.name, d.price, d.image, d.description, d.active, c.name AS category_name " +
                     "FROM drinks d LEFT JOIN categories c ON d.category_id = c.id WHERE d.active = 1 AND d.category_id = ? ORDER BY d.name";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setInt(1, categoryId);
            rs  = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return list;
    }

    public List<Drink> search(String keyword, int categoryId, Boolean active) {
        List<Drink> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT d.id, d.category_id, d.name, d.price, d.image, d.description, d.active, c.name AS category_name " +
            "FROM drinks d LEFT JOIN categories c ON d.category_id = c.id WHERE 1=1");
        if (keyword != null && !keyword.isEmpty()) sql.append(" AND d.name LIKE ?");
        if (categoryId > 0) sql.append(" AND d.category_id = ?");
        if (active != null) sql.append(" AND d.active = ?");
        sql.append(" ORDER BY d.id");

        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql.toString());
            int idx = 1;
            if (keyword != null && !keyword.isEmpty()) ps.setString(idx++, "%" + keyword + "%");
            if (categoryId > 0) ps.setInt(idx++, categoryId);
            if (active != null) ps.setBoolean(idx, active);
            rs = ps.executeQuery();
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return list;
    }

    public Drink findById(int id) {
        String sql = "SELECT d.id, d.category_id, d.name, d.price, d.image, d.description, d.active, c.name AS category_name " +
                     "FROM drinks d LEFT JOIN categories c ON d.category_id = c.id WHERE d.id = ?";
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

    public boolean insert(Drink drink) {
        String sql = "INSERT INTO drinks (category_id, name, price, image, description, active) VALUES (?, ?, ?, ?, ?, ?)";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setInt(1, drink.getCategoryId());
            ps.setString(2, drink.getName());
            ps.setDouble(3, drink.getPrice());
            ps.setString(4, drink.getImage());
            ps.setString(5, drink.getDescription());
            ps.setBoolean(6, drink.isActive());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    public boolean update(Drink drink) {
        String sql = "UPDATE drinks SET category_id=?, name=?, price=?, image=?, description=?, active=? WHERE id=?";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sql);
            ps.setInt(1, drink.getCategoryId());
            ps.setString(2, drink.getName());
            ps.setDouble(3, drink.getPrice());
            ps.setString(4, drink.getImage());
            ps.setString(5, drink.getDescription());
            ps.setBoolean(6, drink.isActive());
            ps.setInt(7, drink.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    /**
     * Xóa đồ uống — chỉ được xóa khi đồ uống chưa từng được bán (không có trong bill_details).
     * Trả về: 1 = xóa thành công, 0 = không tìm thấy, -1 = đã được bán (không thể xóa)
     */
    public int delete(int id) {
        String sqlCheck = "SELECT COUNT(1) FROM bill_details WHERE drink_id = ?";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sqlCheck);
            ps.setInt(1, id);
            rs  = ps.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) return -1;
            JdbcUtil.close(rs, ps); rs = null;

            String sql = "DELETE FROM drinks WHERE id = ?";
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0 ? 1 : 0;
        } catch (SQLException e) { e.printStackTrace(); return 0; }
        finally { JdbcUtil.close(rs, ps, con); }
    }

    public boolean toggleActive(int id) {
        String sql = "UPDATE drinks SET active = ~active WHERE id = ?";
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

    private Drink map(ResultSet rs) throws SQLException {
        Drink d = new Drink();
        d.setId(rs.getInt("id"));
        d.setCategoryId(rs.getInt("category_id"));
        d.setName(rs.getString("name"));
        d.setPrice(rs.getDouble("price"));
        d.setImage(rs.getString("image"));
        d.setDescription(rs.getString("description"));
        d.setActive(rs.getBoolean("active"));
        try { d.setCategoryName(rs.getString("category_name")); } catch (SQLException ignored) {}
        return d;
    }
    public boolean existsByName(String name, int excludeId) {
        String sql = "SELECT COUNT(*) FROM drinks WHERE LOWER(name) = LOWER(?) AND id != ?";
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
