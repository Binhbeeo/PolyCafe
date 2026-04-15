package com.polycoffee.servlet;

import com.polycoffee.dao.UserDAO;
import com.polycoffee.entity.User;
import com.polycoffee.util.AuthUtil;
import com.polycoffee.util.ParamUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet({"/login", "/logout"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uri = req.getRequestURI();

        if (uri.endsWith("/logout")) {
            AuthUtil.clear(req);
            // No-cache sau khi logout
            resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
            resp.setHeader("Pragma", "no-cache");
            resp.setDateHeader("Expires", 0);
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Nếu đã đăng nhập -> redirect, không cho vào lại trang login
        if (AuthUtil.isAuthenticated(req)) {
            redirectHome(req, resp);
            return;
        }

        // No-cache cho trang login để sau khi login bấm back không vào lại được
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email    = ParamUtil.getString(req, "email");
        String password = ParamUtil.getString(req, "password");

        if (email.isEmpty() || password.isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ email và mật khẩu.");
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
            return;
        }

        User user = userDAO.findByEmailAndPassword(email, password);
        if (user == null) {
            req.setAttribute("error", "Email hoặc mật khẩu không đúng.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
            return;
        }

        AuthUtil.setUser(req, user);

        // No-cache sau khi login để bấm back không quay lại trang login
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        redirectHome(req, resp);
    }

    private void redirectHome(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        if (AuthUtil.isManager(req)) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        } else {
            resp.sendRedirect(req.getContextPath() + "/staff/bills");
        }
    }
}
