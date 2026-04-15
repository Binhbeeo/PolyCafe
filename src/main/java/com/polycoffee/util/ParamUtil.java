package com.polycoffee.util;

import jakarta.servlet.http.HttpServletRequest;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * ParamUtil - Tiện ích đọc tham số request
 */
public class ParamUtil {

    /** Trả về giá trị kiểu String, trả về "" nếu null */
    public static String getString(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return (value != null) ? value.trim() : "";
    }

    /** Trả về giá trị kiểu int, trả về defaultValue nếu lỗi */
    public static int getInt(HttpServletRequest request, String name, int defaultValue) {
        try {
            String value = request.getParameter(name);
            if (value == null || value.trim().isEmpty()) return defaultValue;
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** Trả về giá trị kiểu int, defaultValue = 0 */
    public static int getInt(HttpServletRequest request, String name) {
        return getInt(request, name, 0);
    }

    /** Trả về giá trị kiểu long */
    public static long getLong(HttpServletRequest request, String name, long defaultValue) {
        try {
            String value = request.getParameter(name);
            if (value == null || value.trim().isEmpty()) return defaultValue;
            return Long.parseLong(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** Trả về giá trị kiểu double */
    public static double getDouble(HttpServletRequest request, String name, double defaultValue) {
        try {
            String value = request.getParameter(name);
            if (value == null || value.trim().isEmpty()) return defaultValue;
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    /** Trả về giá trị kiểu Date theo pattern */
    public static Date getDate(HttpServletRequest request, String name, String pattern) {
        try {
            String value = request.getParameter(name);
            if (value == null || value.trim().isEmpty()) return null;
            return new SimpleDateFormat(pattern).parse(value.trim());
        } catch (ParseException e) {
            return null;
        }
    }

    /** Trả về boolean */
    public static boolean getBoolean(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return "true".equalsIgnoreCase(value) || "1".equals(value) || "on".equalsIgnoreCase(value);
    }
}
