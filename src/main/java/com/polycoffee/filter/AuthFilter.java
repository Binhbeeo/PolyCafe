package com.polycoffee.filter;

import com.polycoffee.util.AuthUtil;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebFilter({"/admin/*", "/staff/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig fc) {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest)  req;
        HttpServletResponse response = (HttpServletResponse) res;

        // Không cho browser cache các trang admin/staff
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate, private");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        String uri = request.getRequestURI();

        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (uri.startsWith(request.getContextPath() + "/admin/") && !AuthUtil.isManager(request)) {
            response.sendRedirect(request.getContextPath() + "/staff/bills");
            return;
        }

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {}
}
