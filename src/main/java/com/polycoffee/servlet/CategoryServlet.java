package com.polycoffee.servlet;

import com.polycoffee.dao.CategoryDAO;
import com.polycoffee.entity.Category;
import com.polycoffee.util.ParamUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;


@WebServlet("/admin/categories")
public class CategoryServlet extends HttpServlet {

    private final CategoryDAO dao = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = ParamUtil.getString(req, "action");
        int id = ParamUtil.getInt(req, "id");

        switch (action) {
            case "add":
                req.getRequestDispatcher("/views/admin/category-form.jsp").forward(req, resp);
                break;
            case "edit":
                Category cat = dao.findById(id);
                if (cat == null) { resp.sendRedirect(req.getContextPath() + "/admin/categories"); return; }
                req.setAttribute("category", cat);
                req.getRequestDispatcher("/views/admin/category-form.jsp").forward(req, resp);
                break;
            case "delete":
                int catDelResult = dao.delete(id);
                if (catDelResult == -1) {
                    req.setAttribute("error", "Không thể xóa loại đồ uống đang có sản phẩm. Hãy xóa hoặc chuyển toàn bộ đồ uống trước.");
                    req.setAttribute("categories", dao.findAll());
                    req.getRequestDispatcher("/views/admin/category-list.jsp").forward(req, resp);
                    return;
                }
                resp.sendRedirect(req.getContextPath() + "/admin/categories?msg=deleted");
                break;
            case "toggle":
                dao.toggleActive(id);
                resp.sendRedirect(req.getContextPath() + "/admin/categories");
                break;
            default:
                req.setAttribute("categories", dao.findAll());
                req.getRequestDispatcher("/views/admin/category-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int id      = ParamUtil.getInt(req, "id");
        String name = ParamUtil.getString(req, "name");
        boolean active = ParamUtil.getBoolean(req, "active");

        // Validate
        if (name.isEmpty()) {
            req.setAttribute("error", "Tên danh mục không được để trống.");
            if (id > 0) req.setAttribute("category", dao.findById(id));
            req.getRequestDispatcher("/views/admin/category-form.jsp").forward(req, resp);
            return;
        }
        if (dao.existsByName(name, id)) {
            req.setAttribute("error", "Tên danh mục đã tồn tại.");
            if (id > 0) req.setAttribute("category", dao.findById(id));
            req.getRequestDispatcher("/views/admin/category-form.jsp").forward(req, resp);
            return;
        }

        Category cat = new Category(id, name, active);
        if (id == 0) {
            dao.insert(cat);
        } else {
            dao.update(cat);
        }
        resp.sendRedirect(req.getContextPath() + "/admin/categories?msg=saved");
    }
}
