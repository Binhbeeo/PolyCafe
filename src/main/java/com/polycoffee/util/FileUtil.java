package com.polycoffee.util;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.util.Base64;

/**
 * FileUtil - Tiện ích upload ảnh lưu dạng Base64 vào CSDL
 * Không lưu file vật lý, ảnh được encode thành data URI
 * và lưu thẳng vào cột image (NVARCHAR(MAX))
 */
public class FileUtil {

    /**
     * Đọc file ảnh từ request, trả về chuỗi Base64 data URI.
     * Ví dụ: "data:image/jpeg;base64,/9j/4AAQSkZJRgAB..."
     * Trả về null nếu không có file hoặc lỗi.
     */
    public static String upload(HttpServletRequest request, String name) {
        try {
            Part part = request.getPart(name);
            if (part == null || part.getSize() == 0) return null;

            String originalName = part.getSubmittedFileName();
            if (originalName == null || originalName.isEmpty()) return null;

            // Kiểm tra định dạng ảnh
            String ext = originalName.substring(originalName.lastIndexOf('.') + 1).toLowerCase();
            if (!ext.matches("jpg|jpeg|png|gif|webp")) return null;

            // Xác định MIME type
            String mimeType;
            switch (ext) {
                case "jpg": case "jpeg": mimeType = "image/jpeg"; break;
                case "png":              mimeType = "image/png";  break;
                case "gif":              mimeType = "image/gif";  break;
                case "webp":             mimeType = "image/webp"; break;
                default:                 mimeType = "image/jpeg";
            }

            // Đọc toàn bộ bytes của file rồi encode Base64
            InputStream is = part.getInputStream();
            byte[] bytes = is.readAllBytes();
            is.close();

            String base64 = Base64.getEncoder().encodeToString(bytes);
            return "data:" + mimeType + ";base64," + base64;

        } catch (IOException | ServletException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Không cần xóa file vật lý vì ảnh lưu trong DB.
     * Giữ method để không phải sửa chỗ gọi cũ.
     */
    public static void delete(HttpServletRequest request, String imageData) {
        // Base64 lưu trong DB, không có file vật lý để xóa
    }

    /**
     * Trả về src để hiển thị ảnh.
     * Nếu imageData là Base64 data URI → trả về luôn.
     * Nếu null/rỗng → trả về ảnh placeholder.
     */
    public static String getImageUrl(HttpServletRequest request, String imageData) {
        if (imageData == null || imageData.isEmpty()) {
            return request.getContextPath() + "/assets/images/no-image.png";
        }
        return imageData;
    }
}
