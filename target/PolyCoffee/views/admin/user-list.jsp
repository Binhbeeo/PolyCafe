<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,com.polycoffee.entity.User" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Nhân viên – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="_header.jsp" %>

<div class="page-header">
    <h2>👥 Quản lý tài khoản</h2>
    <a href="${pageContext.request.contextPath}/admin/users?action=add" class="btn btn-primary">+ Thêm nhân viên</a>
</div>

<% if ("saved".equals(request.getParameter("msg"))) { %>
<div class="alert alert-success">Lưu thành công!</div>
<% } %>

<div class="card">
    <table class="table">
        <thead>
            <tr><th>ID</th><th>Họ tên</th><th>Email</th><th>SĐT</th><th>Vai trò</th><th>Trạng thái</th><th>Thao tác</th></tr>
        </thead>
        <tbody>
        <%
            List<User> users = (List<User>) request.getAttribute("users");
            if (users != null) for (User u : users) {
        %>
        <tr>
            <td><%= u.getId() %></td>
            <td><%= u.getFullName() %></td>
            <td><%= u.getEmail() %></td>
            <td><%= u.getPhone() != null ? u.getPhone() : "" %></td>
            <td><span class="badge <%= u.isAdmin() ? "purple" : "blue" %>"><%= u.isAdmin() ? "Admin" : "Nhân viên" %></span></td>
            <td>
                <% if (u.isActive()) { %><span class="badge green">Hoạt động</span>
                <% } else { %><span class="badge gray">Đã khóa</span><% } %>
            </td>
            <td>
                <a href="${pageContext.request.contextPath}/admin/users?action=edit&id=<%= u.getId() %>" class="btn btn-sm btn-outline">Sửa</a>
                <a href="${pageContext.request.contextPath}/admin/users?action=toggle&id=<%= u.getId() %>"
                   class="btn btn-sm <%= u.isActive() ? "btn-danger" : "btn-warning" %>"
                   onclick="return confirm('<%= u.isActive() ? "Khóa" : "Mở khóa" %> tài khoản này?')">
                    <%= u.isActive() ? "Khóa" : "Mở khóa" %>
                </a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

</main></div>
</body>
</html>
