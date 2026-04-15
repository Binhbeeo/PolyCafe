<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.polycoffee.util.AuthUtil" %>
<%
    com.polycoffee.entity.User currentUser = AuthUtil.getUser(request);
    boolean isAdmin = AuthUtil.isManager(request);
    String ctx = request.getContextPath();
%>
<nav style="background:#6f4e37;color:#fff;display:flex;align-items:center;justify-content:space-between;padding:0 16px;height:56px;position:sticky;top:0;z-index:100;box-shadow:0 2px 6px rgba(0,0,0,.25);width:100%;box-sizing:border-box;">
    <div style="font-size:16px;font-weight:700;white-space:nowrap;flex-shrink:0;">☕ PolyCoffee</div>
    <div style="display:flex;align-items:center;gap:8px;flex-shrink:0;">
        <span style="font-size:12px;white-space:nowrap;">👤 <%= currentUser != null ? currentUser.getFullName() : "" %></span>
        <% if (isAdmin) { %>
        <span style="font-size:11px;padding:2px 8px;border-radius:12px;font-weight:600;white-space:nowrap;background:#f6ad55;color:#7b341e;">Quản lý</span>
        <% } else { %>
        <span style="font-size:11px;padding:2px 8px;border-radius:12px;font-weight:600;white-space:nowrap;background:#90cdf4;color:#2c5282;">Nhân viên</span>
        <% } %>
        <a href="<%= ctx %>/logout" style="white-space:nowrap;padding:5px 12px;border-radius:6px;border:1.5px solid #fff;color:#fff;font-size:13px;text-decoration:none;">Đăng xuất</a>
    </div>
</nav>
<div class="layout">
    <aside class="sidebar">
        <ul class="sidebar-menu">
            <% if (isAdmin) { %>
            <li><a href="<%= ctx %>/admin/dashboard">📊 Tổng quan</a></li>
            <li><a href="<%= ctx %>/admin/categories">🗂️ Danh mục</a></li>
            <li><a href="<%= ctx %>/admin/drinks">🥤 Đồ uống</a></li>
            <li><a href="<%= ctx %>/admin/bills">🧾 Hóa đơn</a></li>
            <li><a href="<%= ctx %>/admin/users">👥 Nhân viên</a></li>
            <li><a href="<%= ctx %>/admin/reports">📈 Báo cáo</a></li>
            <% } else { %>
            <li><a href="<%= ctx %>/staff/bills?action=new">➕ Tạo đơn</a></li>
            <li><a href="<%= ctx %>/staff/bills">🧾 Đơn của tôi</a></li>
            <li><a href="<%= ctx %>/staff/profile">👤 Tài khoản</a></li>
            <% } %>
        </ul>
    </aside>
    <main class="main-content">
