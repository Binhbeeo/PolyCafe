package com.polycoffee.util;

import com.polycoffee.entity.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

/**
 * AuthUtil - Tiện ích quản lý đăng nhập và phân quyền
 */
public class AuthUtil {

    private static final String SESSION_KEY = "CURRENT_USER";

    /** Lưu thông tin user vào session */
    public static void setUser(HttpServletRequest request, User user) {
        request.getSession().setAttribute(SESSION_KEY, user);
    }

    /** Lấy thông tin user đăng nhập từ session */
    public static User getUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute(SESSION_KEY);
    }

    /** Kiểm tra đã đăng nhập chưa */
    public static boolean isAuthenticated(HttpServletRequest request) {
        return getUser(request) != null;
    }

    /** Kiểm tra có phải quản lý (admin) không */
    public static boolean isManager(HttpServletRequest request) {
        User user = getUser(request);
        return user != null && "admin".equalsIgnoreCase(user.getRole());
    }

    /** Kiểm tra có phải nhân viên (staff) không */
    public static boolean isStaff(HttpServletRequest request) {
        User user = getUser(request);
        return user != null && "staff".equalsIgnoreCase(user.getRole());
    }

    /** Xóa thông tin user khỏi session (đăng xuất) */
    public static void clear(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }
}
