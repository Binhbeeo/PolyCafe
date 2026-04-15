<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.polycoffee.entity.User" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tài khoản – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="../admin/_header.jsp" %>

<%
    User u = (User) request.getAttribute("user");
    if (u == null) u = com.polycoffee.util.AuthUtil.getUser(request);
%>

<div class="page-header">
    <h2>👤 Tài khoản của tôi</h2>
</div>

<!-- Thông tin tài khoản -->
<div class="card" style="max-width:480px">
    <div class="card-header">Thông tin cá nhân</div>
    <div class="card-body">
        <table class="table table-simple">
            <tr><td>Họ tên</td><td><strong><%= u.getFullName() %></strong></td></tr>
            <tr><td>Email</td><td><%= u.getEmail() %></td></tr>
            <tr><td>SĐT</td><td><%= u.getPhone() != null ? u.getPhone() : "—" %></td></tr>
            <tr><td>Vai trò</td><td><span class="badge <%= u.isAdmin() ? "purple" : "blue" %>"><%= u.isAdmin() ? "Quản lý" : "Nhân viên" %></span></td></tr>
        </table>
    </div>
</div>

<!-- Đổi mật khẩu -->
<div class="card mt-4" style="max-width:480px">
    <div class="card-header">🔐 Đổi mật khẩu</div>
    <div class="card-body">
        <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
        <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/staff/profile">
            <input type="hidden" name="action" value="changePassword">

            <div class="form-group">
                <label>Mật khẩu hiện tại</label>
                <input type="password" name="oldPassword" class="form-control" required>
            </div>
            <div class="form-group">
                <label>Mật khẩu mới</label>
                <input type="password" name="newPassword" class="form-control" required minlength="6">
            </div>
            <div class="form-group">
                <label>Xác nhận mật khẩu mới</label>
                <input type="password" name="confirmPassword" class="form-control" required minlength="6">
            </div>
            <button type="submit" class="btn btn-primary">💾 Đổi mật khẩu</button>
        </form>
    </div>
</div>

</main></div>
</body>
</html>
