package com.polycoffee.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;

/**
 * Utf8Filter - Đảm bảo encoding UTF-8 cho mọi request/response
 */
@WebFilter("/*")
public class Utf8Filter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
