package com.polycoffee.util;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * FileUtil - Tiện ích upload ảnh lên ImgBB và lưu URL vào CSDL
 */
public class FileUtil {

    // API Key của ImgBB (Người dùng nên thay thế bằng key cá nhân nếu cần)
    private static final String IMGBB_API_KEY = "677f59f9976375005953326164228490";
    private static final String IMGBB_API_URL = "https://api.imgbb.com/1/upload";

    /**
     * Tải ảnh lên ImgBB và trả về URL trực tiếp của ảnh.
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

            // Đọc toàn bộ bytes của file rồi encode Base64 để gửi lên ImgBB
            InputStream is = part.getInputStream();
            byte[] bytes = is.readAllBytes();
            is.close();
            String base64Image = Base64.getEncoder().encodeToString(bytes);

            // Gửi request POST đến ImgBB API
            return uploadToImgBB(base64Image);

        } catch (IOException | ServletException e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Gọi API ImgBB để upload ảnh Base64
     */
    private static String uploadToImgBB(String base64Image) {
        try {
            HttpClient client = HttpClient.newHttpClient();
            
            // Body dạng x-www-form-urlencoded
            String form = "key=" + IMGBB_API_KEY + "&image=" + URLEncoder.encode(base64Image, StandardCharsets.UTF_8);

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(IMGBB_API_URL))
                    .header("Content-Type", "application/x-www-form-urlencoded")
                    .POST(HttpRequest.BodyPublishers.ofString(form))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                // Parse JSON thủ công để lấy URL (để tránh thêm dependency JSON)
                String body = response.body();
                Pattern pattern = Pattern.compile("\"url\":\"(.*?)\"");
                Matcher matcher = pattern.matcher(body);
                if (matcher.find()) {
                    // Trả về URL và thay thế các dấu gạch chéo ngược (nếu có)
                    return matcher.group(1).replace("\\/", "/");
                }
            } else {
                System.err.println("ImgBB Upload Error: " + response.body());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Không cần xóa file vật lý vì ảnh lưu trên cloud ImgBB.
     */
    public static void delete(HttpServletRequest request, String imageData) {
        // ImgBB free API không hỗ trợ xóa qua API đơn giản mà không có delete_url
    }

    /**
     * Trả về src để hiển thị ảnh.
     * Nếu imageData là URL hoặc Base64 → trả về luôn.
     * Nếu null/rỗng → trả về ảnh placeholder.
     */
    public static String getImageUrl(HttpServletRequest request, String imageData) {
        if (imageData == null || imageData.isEmpty()) {
            // Placeholder image
            return "https://via.placeholder.com/150?text=No+Image";
        }
        return imageData;
    }
}
