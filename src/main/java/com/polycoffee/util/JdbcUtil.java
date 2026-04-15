package com.polycoffee.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * JdbcUtil - Lớp tiện ích kết nối cơ sở dữ liệu SQL Server
 */
public class JdbcUtil {

    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    private static final String DB_HOST = System.getenv("DB_HOST") != null ? System.getenv("DB_HOST") : "polyphone-db-2026.database.windows.net";
    private static final String DB_NAME = System.getenv("DB_NAME") != null ? System.getenv("DB_NAME") : "PolyCoffeeDB";
    private static final String URL     = String.format("jdbc:sqlserver://%s;databaseName=%s;encrypt=false;trustServerCertificate=true", DB_HOST, DB_NAME);
    private static final String USER    = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "Binhbeo";
    private static final String PASS    = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "Beohub123@";

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
