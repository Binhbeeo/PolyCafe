package com.polycoffee.util;

import jakarta.servlet.http.HttpServletRequest;

/**
 * FileUtil - Tiện ích hiển thị ảnh từ URL
 */
public class FileUtil {

    /**
     * Không còn hỗ trợ upload file trực tiếp. 
     * Người dùng sẽ nhập URL từ các dịch vụ như ImgBB.
     */
    public static String upload(HttpServletRequest request, String name) {
        return null;
    }

    /**
     * Không cần xóa file vì ảnh được lưu trữ bên ngoài (URL).
     */
    public static void delete(HttpServletRequest request, String imageData) {
    }

    /**
     * Trả về src để hiển thị ảnh.
     * Nếu imageData là URL hoặc Base64 → trả về luôn.
     * Nếu null/rỗng → trả về ảnh placeholder.
     */
    public static String getImageUrl(HttpServletRequest request, String imageData) {
        if (imageData == null || imageData.trim().isEmpty()) {
            // Placeholder image
            return "https://via.placeholder.com/150?text=No+Image";
        }
        return imageData.trim();
    }
}
