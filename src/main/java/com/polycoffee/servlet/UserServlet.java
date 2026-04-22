package com.polycoffee.servlet;

import com.polycoffee.dao.UserDAO;
import com.polycoffee.entity.User;
import com.polycoffee.util.AuthUtil;
import com.polycoffee.util.ParamUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet({"/admin/users", "/staff/profile"})
public class UserServlet extends HttpServlet {

    private final UserDAO dao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uri    = req.getRequestURI();
        String action = ParamUtil.getString(req, "action");
        int id        = ParamUtil.getInt(req, "id");

        // -- Staff: xem profile của mình --
        if (uri.contains("/staff/profile")) {
            req.setAttribute("user", AuthUtil.getUser(req));
            req.getRequestDispatcher("/views/staff/profile.jsp").forward(req, resp);
            return;
        }

        // -- Admin: quản lý nhân viên --
        switch (action) {
            case "add":
                req.getRequestDispatcher("/views/admin/user-form.jsp").forward(req, resp);
                break;
            case "edit":
                User u = dao.findById(id);
                if (u == null) { resp.sendRedirect(req.getContextPath() + "/admin/users"); return; }
                req.setAttribute("editUser", u);
                req.getRequestDispatcher("/views/admin/user-form.jsp").forward(req, resp);
                break;
            case "toggle":
                dao.toggleActive(id);
                resp.sendRedirect(req.getContextPath() + "/admin/users");
                break;
            default:
                req.setAttribute("users", dao.findAll());
                req.getRequestDispatcher("/views/admin/user-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uri = req.getRequestURI();

        // -- Đổi mật khẩu (staff/admin) --
        if ("changePassword".equals(ParamUtil.getString(req, "action"))) {
            User current  = AuthUtil.getUser(req);
            String oldPwd = ParamUtil.getString(req, "oldPassword");
            String newPwd = ParamUtil.getString(req, "newPassword");
            String cfmPwd = ParamUtil.getString(req, "confirmPassword");

            if (!newPwd.equals(cfmPwd) || newPwd.length() < 6) {
                req.setAttribute("error", "Mật khẩu mới không khớp hoặc quá ngắn (tối thiểu 6 ký tự).");
                req.setAttribute("user", current);
                req.getRequestDispatcher("/views/staff/profile.jsp").forward(req, resp);
                return;
            }
            boolean ok = dao.changePassword(current.getId(), oldPwd, newPwd);
            if (ok) {
                req.setAttribute("success", "Đổi mật khẩu thành công!");
            } else {
                req.setAttribute("error", "Mật khẩu cũ không đúng.");
            }
            req.setAttribute("user", AuthUtil.getUser(req));
            req.getRequestDispatcher("/views/staff/profile.jsp").forward(req, resp);
            return;
        }

        // -- Admin: thêm / sửa nhân viên --
        int     id       = ParamUtil.getInt(req, "id");
        String  email    = ParamUtil.getString(req, "email");
        String  password = ParamUtil.getString(req, "password");
        String  fullName = ParamUtil.getString(req, "fullName");
        String  phone    = ParamUtil.getString(req, "phone");
        String  role     = ParamUtil.getString(req, "role");
        boolean active   = ParamUtil.getBoolean(req, "active");

        if (fullName.isEmpty() || email.isEmpty()) {
            req.setAttribute("error", "Vui lòng điền đầy đủ thông tin.");
            if (id > 0) req.setAttribute("editUser", dao.findById(id));
            req.getRequestDispatcher("/views/admin/user-form.jsp").forward(req, resp);
            return;
        }
        if (dao.existsByPhone(phone, id)) {
            req.setAttribute("error", "Số điện thoại đã được sử dụng bởi tài khoản khác.");
            if (id > 0) req.setAttribute("editUser", dao.findById(id));
            req.getRequestDispatcher("/views/admin/user-form.jsp").forward(req, resp);
            return;
        }

        if (id == 0) {
            if (password.length() < 6) {
                req.setAttribute("error", "Mật khẩu tối thiểu 6 ký tự.");
                req.getRequestDispatcher("/views/admin/user-form.jsp").forward(req, resp);
                return;
            }
            User u = new User();
            u.setEmail(email); u.setPassword(password); u.setFullName(fullName);
            u.setPhone(phone); u.setRole(role.isEmpty() ? "staff" : role); u.setActive(true);
            if (!dao.insert(u)) {
                req.setAttribute("error", "Email đã tồn tại trong hệ thống.");
                req.getRequestDispatcher("/views/admin/user-form.jsp").forward(req, resp);
                return;
            }
        } else {
            User u = dao.findById(id);
            if (u == null) { resp.sendRedirect(req.getContextPath() + "/admin/users"); return; }
            u.setEmail(email); u.setFullName(fullName); u.setPhone(phone);
            u.setRole(role.isEmpty() ? u.getRole() : role); u.setActive(active);
            if (!dao.update(u)) {
                req.setAttribute("error", "Email đã tồn tại trong hệ thống.");
                req.setAttribute("editUser", u);
                req.getRequestDispatcher("/views/admin/user-form.jsp").forward(req, resp);
                return;
            }
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users?msg=saved");
    }
}
