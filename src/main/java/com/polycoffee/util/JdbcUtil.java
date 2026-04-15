package com.polycoffee.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * JdbcUtil - Lớp tiện ích kết nối cơ sở dữ liệu SQL Server
 */
public class JdbcUtil {

    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    private static final String URL    = "jdbc:sqlserver://localhost:1433;databaseName=PolyCoffeeDB;encrypt=false;trustServerCertificate=true";
    private static final String USER   = "sa";
    private static final String PASS   = "123"; // Đổi theo môi trường của bạn

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Không tìm thấy driver SQL Server!", e);
        }
    }

    /**
     * Lấy kết nối đến CSDL
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    /**
     * Đóng kết nối an toàn
     */
    public static void close(AutoCloseable... resources) {
        for (AutoCloseable res : resources) {
            if (res != null) {
                try {
                    res.close();
                } catch (Exception e) {
                    // ignore
                }
            }
        }
    }
}
