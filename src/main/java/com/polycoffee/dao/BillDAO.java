package com.polycoffee.dao;

import com.polycoffee.entity.Bill;
import com.polycoffee.entity.BillDetail;
import com.polycoffee.util.JdbcUtil;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;

/**
 * BillDAO - Thao tác CSDL bảng bills và bill_details
 */
public class BillDAO {

    // ====================================================
    //  CRUD - Bills
    // ====================================================

    public List<Bill> findAll() {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT b.*, u.full_name AS user_full_name FROM bills b " +
                     "LEFT JOIN users u ON b.user_id = u.id ORDER BY b.created_at DESC";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql); rs = ps.executeQuery();
            while (rs.next()) list.add(mapBill(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return list;
    }

    public List<Bill> findByUser(int userId) {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT b.*, u.full_name AS user_full_name FROM bills b " +
                     "LEFT JOIN users u ON b.user_id = u.id WHERE b.user_id = ? ORDER BY b.created_at DESC";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
            ps.setInt(1, userId); rs = ps.executeQuery();
            while (rs.next()) list.add(mapBill(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return list;
    }

    public List<Bill> findByStatus(String status) {
        List<Bill> list = new ArrayList<>();
        String sql = "SELECT b.*, u.full_name AS user_full_name FROM bills b " +
                     "LEFT JOIN users u ON b.user_id = u.id WHERE b.status = ? ORDER BY b.created_at DESC";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
            ps.setString(1, status); rs = ps.executeQuery();
            while (rs.next()) list.add(mapBill(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return list;
    }

    public Bill findById(int id) {
        String sql = "SELECT b.*, u.full_name AS user_full_name FROM bills b " +
                     "LEFT JOIN users u ON b.user_id = u.id WHERE b.id = ?";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
            ps.setInt(1, id); rs = ps.executeQuery();
            if (rs.next()) {
                Bill bill = mapBill(rs);
                bill.setDetails(findDetails(id));
                return bill;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return null;
    }

    // ====================================================
    //  Business Logic
    // ====================================================

    /**
     * Tạo hóa đơn cùng nhiều sản phẩm (Transaction)
     * @param userId   ID nhân viên tạo đơn
     * @param items    Map<drinkId, quantity>
     * @param prices   Map<drinkId, price>
     * @return ID hóa đơn mới, -1 nếu lỗi
     */
    public int createBillWithDetails(int userId, Map<Integer, Integer> items, Map<Integer, Double> prices) {
        Connection con = null;
        try {
            con = JdbcUtil.getConnection();
            con.setAutoCommit(false);

            // 1. Tạo hóa đơn rỗng
            String code = "PC" + new SimpleDateFormat("yyyyMMddHHmmss").format(new Date()) + userId;
            String sqlBill = "INSERT INTO bills (user_id, code, created_at, total, status) VALUES (?, ?, GETDATE(), 0, 'waiting')";
            PreparedStatement psBill = con.prepareStatement(sqlBill, Statement.RETURN_GENERATED_KEYS);
            psBill.setInt(1, userId);
            psBill.setString(2, code);
            psBill.executeUpdate();

            // 2. Lấy ID hóa đơn vừa tạo
            ResultSet keys = psBill.getGeneratedKeys();
            if (!keys.next()) { con.rollback(); return -1; }
            int billId = keys.getInt(1);
            psBill.close();

            // 3. Thêm lần lượt từng thức uống vào hóa đơn vừa tạo
            String sqlDetail = "INSERT INTO bill_details (bill_id, drink_id, quantity, price) VALUES (?, ?, ?, ?)";
            PreparedStatement psDetail = con.prepareStatement(sqlDetail);
            double total = 0;
            for (Map.Entry<Integer, Integer> entry : items.entrySet()) {
                int drinkId  = entry.getKey();
                int qty      = entry.getValue();
                double price = prices.getOrDefault(drinkId, 0.0);
                psDetail.setInt(1, billId);
                psDetail.setInt(2, drinkId);
                psDetail.setInt(3, qty);
                psDetail.setDouble(4, price);
                psDetail.addBatch();
                total += qty * price;
            }
            psDetail.executeBatch();
            psDetail.close();

            // 4. Cập nhật lại tổng tiền của hóa đơn
            PreparedStatement psTotal = con.prepareStatement("UPDATE bills SET total=? WHERE id=?");
            psTotal.setDouble(1, total);
            psTotal.setInt(2, billId);
            psTotal.executeUpdate();
            psTotal.close();

            con.commit();
            // 5. Tạo hóa đơn và thêm thức uống thành công trả về ID hóa đơn
            return billId;

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (con != null) con.rollback(); } catch (SQLException ignored) {}
            return -1;
        } finally {
            try { if (con != null) { con.setAutoCommit(true); con.close(); } } catch (SQLException ignored) {}
        }
    }

    /**
     * Thêm đồ uống vào hóa đơn đang ở trạng thái waiting.
     * - Nếu đồ uống đã có trong hóa đơn → tăng số lượng lên 1
     * - Nếu chưa có → thêm mới với số lượng = 1
     * Chỉ thực hiện khi hóa đơn đang ở trạng thái "waiting"
     */
    public boolean addDrinkToBill(int billId, int drinkId, double price) {
        Bill bill = findById(billId);
        if (bill == null || !"waiting".equals(bill.getStatus())) return false;

        // Kiểm tra đồ uống đã có trong hóa đơn chưa
        String sqlCheck = "SELECT id, quantity FROM bill_details WHERE bill_id = ? AND drink_id = ?";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection();
            ps  = con.prepareStatement(sqlCheck);
            ps.setInt(1, billId); ps.setInt(2, drinkId);
            rs  = ps.executeQuery();
            if (rs.next()) {
                // Đã có → tăng số lượng lên 1
                int currentQty = rs.getInt("quantity");
                JdbcUtil.close(rs, ps);
                String sqlUpdate = "UPDATE bill_details SET quantity = ? WHERE bill_id = ? AND drink_id = ?";
                ps = con.prepareStatement(sqlUpdate);
                ps.setInt(1, currentQty + 1); ps.setInt(2, billId); ps.setInt(3, drinkId);
                ps.executeUpdate();
            } else {
                // Chưa có → thêm mới
                JdbcUtil.close(rs, ps);
                String sqlInsert = "INSERT INTO bill_details (bill_id, drink_id, quantity, price) VALUES (?, ?, 1, ?)";
                ps = con.prepareStatement(sqlInsert);
                ps.setInt(1, billId); ps.setInt(2, drinkId); ps.setDouble(3, price);
                ps.executeUpdate();
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(rs, ps, con); }

        recalculateTotal(billId);
        return true;
    }

    /**
     * Cập nhật số lượng sản phẩm trong hóa đơn (chỉ khi status = waiting)
     */
    public boolean updateDetailQuantity(int billId, int drinkId, int quantity) {
        // Kiểm tra trạng thái
        Bill bill = findById(billId);
        if (bill == null || !"waiting".equals(bill.getStatus())) return false;

        if (quantity <= 0) {
            // Xóa dòng chi tiết
            String sql = "DELETE FROM bill_details WHERE bill_id=? AND drink_id=?";
            Connection con = null; PreparedStatement ps = null;
            try {
                con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
                ps.setInt(1, billId); ps.setInt(2, drinkId);
                ps.executeUpdate();
            } catch (SQLException e) { e.printStackTrace(); return false; }
            finally { JdbcUtil.close(ps, con); }
        } else {
            String sql = "UPDATE bill_details SET quantity=? WHERE bill_id=? AND drink_id=?";
            Connection con = null; PreparedStatement ps = null;
            try {
                con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
                ps.setInt(1, quantity); ps.setInt(2, billId); ps.setInt(3, drinkId);
                ps.executeUpdate();
            } catch (SQLException e) { e.printStackTrace(); return false; }
            finally { JdbcUtil.close(ps, con); }
        }
        recalculateTotal(billId);
        return true;
    }

    /**
     * Cập nhật trạng thái hóa đơn với kiểm tra nghiệp vụ:
     * waiting -> finish | cancel
     * finish  -> cancel (chỉ admin)
     */
    public boolean updateStatus(int billId, String newStatus, boolean isAdmin) {
        Bill bill = findById(billId);
        if (bill == null) return false;

        String cur = bill.getStatus();
        boolean allowed = false;
        if ("waiting".equals(cur) && ("finish".equals(newStatus) || "cancel".equals(newStatus))) allowed = true;
        if ("finish".equals(cur) && "cancel".equals(newStatus) && isAdmin) allowed = true;
        if (!allowed) return false;

        String sql = "UPDATE bills SET status=? WHERE id=?";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
            ps.setString(1, newStatus); ps.setInt(2, billId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
        finally { JdbcUtil.close(ps, con); }
    }

    // ====================================================
    //  Statistics
    // ====================================================

    /** Thống kê doanh thu theo ngày trong khoảng thời gian */
    public List<Map<String, Object>> revenueByDay(Date from, Date to) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT CAST(created_at AS DATE) AS bill_date, COUNT(id) AS total_bills, SUM(total) AS revenue " +
                     "FROM bills WHERE status='finish' AND created_at BETWEEN ? AND ? " +
                     "GROUP BY CAST(created_at AS DATE) ORDER BY bill_date";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
            ps.setDate(1, new java.sql.Date(from.getTime()));
            ps.setDate(2, new java.sql.Date(to.getTime()));
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("date",        rs.getDate("bill_date").toString());
                row.put("totalBills",  rs.getInt("total_bills"));
                row.put("revenue",     rs.getDouble("revenue"));
                result.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return result;
    }

    /** Top sản phẩm bán chạy */
    public List<Map<String, Object>> topDrinks(int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP (?) d.name, c.name AS category_name, SUM(bd.quantity) AS total_sold, " +
                     "SUM(bd.quantity * bd.price) AS total_revenue " +
                     "FROM bill_details bd " +
                     "JOIN drinks d ON bd.drink_id = d.id " +
                     "JOIN categories c ON d.category_id = c.id " +
                     "JOIN bills b ON bd.bill_id = b.id " +
                     "WHERE b.status = 'finish' " +
                     "GROUP BY d.name, c.name ORDER BY total_sold DESC";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
            ps.setInt(1, limit); rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("name",          rs.getString("name"));
                row.put("categoryName",  rs.getString("category_name"));
                row.put("totalSold",     rs.getInt("total_sold"));
                row.put("totalRevenue",  rs.getDouble("total_revenue"));
                result.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return result;
    }

    /** Top sản phẩm bán chạy trong khoảng thời gian */
    public List<Map<String, Object>> topDrinksByDateRange(int limit, Date from, Date to) {
        List<Map<String, Object>> result = new ArrayList<>();
        String sql = "SELECT TOP (?) d.name, c.name AS category_name, SUM(bd.quantity) AS total_sold, " +
                     "SUM(bd.quantity * bd.price) AS total_revenue " +
                     "FROM bill_details bd " +
                     "JOIN drinks d ON bd.drink_id = d.id " +
                     "JOIN categories c ON d.category_id = c.id " +
                     "JOIN bills b ON bd.bill_id = b.id " +
                     "WHERE b.status = 'finish' AND b.created_at >= ? AND b.created_at < DATEADD(day, 1, ?) " +
                     "GROUP BY d.name, c.name ORDER BY total_sold DESC";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setDate(2, new java.sql.Date(from.getTime()));
            ps.setDate(3, new java.sql.Date(to.getTime()));
            rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("name",          rs.getString("name"));
                row.put("categoryName",  rs.getString("category_name"));
                row.put("totalSold",     rs.getInt("total_sold"));
                row.put("totalRevenue",  rs.getDouble("total_revenue"));
                result.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return result;
    }

    // ====================================================
    //  Helpers
    // ====================================================

    private List<BillDetail> findDetails(int billId) {
        List<BillDetail> list = new ArrayList<>();
        String sql = "SELECT bd.*, d.name AS drink_name, d.image AS drink_image " +
                     "FROM bill_details bd JOIN drinks d ON bd.drink_id = d.id WHERE bd.bill_id = ?";
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
            ps.setInt(1, billId); rs = ps.executeQuery();
            while (rs.next()) {
                BillDetail bd = new BillDetail();
                bd.setId(rs.getInt("id"));
                bd.setBillId(rs.getInt("bill_id"));
                bd.setDrinkId(rs.getInt("drink_id"));
                bd.setQuantity(rs.getInt("quantity"));
                bd.setPrice(rs.getDouble("price"));
                bd.setDrinkName(rs.getString("drink_name"));
                bd.setDrinkImage(rs.getString("drink_image"));
                list.add(bd);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(rs, ps, con); }
        return list;
    }

    private void recalculateTotal(int billId) {
        String sql = "UPDATE bills SET total = (SELECT ISNULL(SUM(quantity * price),0) FROM bill_details WHERE bill_id = ?) WHERE id = ?";
        Connection con = null; PreparedStatement ps = null;
        try {
            con = JdbcUtil.getConnection(); ps = con.prepareStatement(sql);
            ps.setInt(1, billId); ps.setInt(2, billId); ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
        finally { JdbcUtil.close(ps, con); }
    }

    private Bill mapBill(ResultSet rs) throws SQLException {
        Bill b = new Bill();
        b.setId(rs.getInt("id"));
        b.setUserId(rs.getInt("user_id"));
        b.setCode(rs.getString("code"));
        b.setCreatedAt(rs.getTimestamp("created_at"));
        b.setTotal(rs.getDouble("total"));
        b.setStatus(rs.getString("status"));
        try { b.setUserFullName(rs.getString("user_full_name")); } catch (SQLException ignored) {}
        return b;
    }
}
