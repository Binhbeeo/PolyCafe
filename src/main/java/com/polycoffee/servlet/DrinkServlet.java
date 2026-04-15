package com.polycoffee.servlet;

import com.polycoffee.dao.CategoryDAO;
import com.polycoffee.dao.DrinkDAO;
import com.polycoffee.entity.Drink;
import com.polycoffee.util.FileUtil;
import com.polycoffee.util.ParamUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/drinks")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024) // 10MB
public class DrinkServlet extends HttpServlet {

    private final DrinkDAO    drinkDAO    = new DrinkDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = ParamUtil.getString(req, "action");
        int id = ParamUtil.getInt(req, "id");

        switch (action) {
            case "add":
                req.setAttribute("categories", categoryDAO.findAllActive());
                req.getRequestDispatcher("/views/admin/drink-form.jsp").forward(req, resp);
                break;
            case "edit":
                Drink drink = drinkDAO.findById(id);
                if (drink == null) { resp.sendRedirect(req.getContextPath() + "/admin/drinks"); return; }
                req.setAttribute("drink", drink);
                req.setAttribute("categories", categoryDAO.findAllActive());
                req.getRequestDispatcher("/views/admin/drink-form.jsp").forward(req, resp);
                break;
            case "delete":
                Drink toDelete = drinkDAO.findById(id);
                if (toDelete != null) {
                    drinkDAO.delete(id);
                }
                resp.sendRedirect(req.getContextPath() + "/admin/drinks?msg=deleted");
                break;
            case "toggle":
                drinkDAO.toggleActive(id);
                resp.sendRedirect(req.getContextPath() + "/admin/drinks");
                break;
            default:
                String keyword    = ParamUtil.getString(req, "keyword");
                int    categoryId = ParamUtil.getInt(req, "categoryId");
                req.setAttribute("drinks",     drinkDAO.search(keyword, categoryId, null));
                req.setAttribute("categories", categoryDAO.findAllActive());
                req.setAttribute("keyword",    keyword);
                req.setAttribute("categoryId", categoryId);
                req.getRequestDispatcher("/views/admin/drink-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int    id          = ParamUtil.getInt(req, "id");
        int    categoryId  = ParamUtil.getInt(req, "categoryId");
        String name        = ParamUtil.getString(req, "name");
        double price       = ParamUtil.getDouble(req, "price", 0);
        String description = ParamUtil.getString(req, "description");
        boolean active     = ParamUtil.getBoolean(req, "active");

        // Validate
        if (name.isEmpty() || categoryId == 0 || price <= 0) {
            req.setAttribute("error", "Vui lòng điền đầy đủ thông tin hợp lệ.");
            req.setAttribute("categories", categoryDAO.findAllActive());
            if (id > 0) req.setAttribute("drink", drinkDAO.findById(id));
            req.getRequestDispatcher("/views/admin/drink-form.jsp").forward(req, resp);
            return;
        }
        if (drinkDAO.existsByName(name, id)) {
            req.setAttribute("error", "Tên đồ uống đã tồn tại.");
            req.setAttribute("categories", categoryDAO.findAllActive());
            if (id > 0) req.setAttribute("drink", drinkDAO.findById(id));
            req.getRequestDispatcher("/views/admin/drink-form.jsp").forward(req, resp);
            return;
        }

        // Xử lý ảnh: ưu tiên file upload, nếu không có thì lấy URL trực tiếp
        String newImage = null;
        
        // Cách 1: Chọn file từ máy (tự động upload lên ImgBB)
        String uploadedUrl = FileUtil.upload(req, "imageFile");
        if (uploadedUrl != null) {
            newImage = uploadedUrl;
        } else {
            // Cách 2: Nhập URL trực tiếp
            String imageUrl = ParamUtil.getString(req, "imageUrl").trim();
            if (!imageUrl.isEmpty()) {
                newImage = imageUrl;
            }
        }

        if (id == 0) {
            // Thêm mới
            Drink drink = new Drink();
            drink.setCategoryId(categoryId);
            drink.setName(name);
            drink.setPrice(price);
            drink.setImage(newImage);
            drink.setDescription(description);
            drink.setActive(active);
            drinkDAO.insert(drink);
        } else {
            // Cập nhật
            Drink existing = drinkDAO.findById(id);
            if (existing == null) { resp.sendRedirect(req.getContextPath() + "/admin/drinks"); return; }

            if (newImage == null) {
                newImage = existing.getImage(); // Giữ ảnh cũ nếu không upload hoặc nhập URL mới
            }

            existing.setCategoryId(categoryId);
            existing.setName(name);
            existing.setPrice(price);
            existing.setImage(newImage);
            existing.setDescription(description);
            existing.setActive(active);
            drinkDAO.update(existing);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/drinks?msg=saved");
    }
}
