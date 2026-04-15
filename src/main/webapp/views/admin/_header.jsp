<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.polycoffee.util.AuthUtil" %>
<%
    com.polycoffee.entity.User currentUser = AuthUtil.getUser(request);
    boolean isAdmin = AuthUtil.isManager(request);
    String ctx = request.getContextPath();

    // No-cache để bấm back không load lại trang đã đăng nhập
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<nav class="navbar">
    <div class="navbar-brand">
        <i class="bi bi-cup-hot"></i>
        <span>PolyCoffee</span>
    </div>
    <div class="navbar-right">
        <div class="navbar-user">
            <i class="bi bi-person-circle"></i>
            <span><%= currentUser != null ? currentUser.getFullName() : "Người dùng" %></span>
            <% if (isAdmin) { %>
            <span class="badge-role admin">Quản lý</span>
            <% } else { %>
            <span class="badge-role staff">Nhân viên</span>
            <% } %>
        </div>
        <a href="<%= ctx %>/logout" class="btn btn-sm" style="background: rgba(255,255,255,0.2); color: #fff; border: 1px solid rgba(255,255,255,0.3);">
            <i class="bi bi-box-arrow-right"></i> Đăng xuất
        </a>
    </div>
</nav>

<div class="layout">
    <aside class="sidebar">
        <ul class="sidebar-menu">
            <% if (isAdmin) { %>
            <li><a href="<%= ctx %>/admin/dashboard"><i class="bi bi-graph-up"></i> Tổng quan</a></li>
            <li><a href="<%= ctx %>/admin/categories"><i class="bi bi-folder"></i> Danh mục</a></li>
            <li><a href="<%= ctx %>/admin/drinks"><i class="bi bi-cup"></i> Đồ uống</a></li>
            <li><a href="<%= ctx %>/admin/bills"><i class="bi bi-receipt"></i> Hóa đơn</a></li>
            <li><a href="<%= ctx %>/admin/users"><i class="bi bi-people"></i> Nhân viên</a></li>
            <li><a href="<%= ctx %>/admin/reports"><i class="bi bi-bar-chart"></i> Báo cáo</a></li>
            <% } else { %>
            <li><a href="<%= ctx %>/staff/bills?action=new"><i class="bi bi-plus-circle"></i> Tạo đơn</a></li>
            <li><a href="<%= ctx %>/staff/bills"><i class="bi bi-receipt"></i> Đơn của tôi</a></li>
            <li><a href="<%= ctx %>/staff/profile"><i class="bi bi-person"></i> Tài khoản</a></li>
            <% } %>
        </ul>
    </aside>
    <main class="main-content">
