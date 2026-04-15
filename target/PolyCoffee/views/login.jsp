<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="login-page">
<div class="login-wrapper">
    <div class="login-card">
        <div class="login-logo">
            <span>☕</span>
            <h1>PolyCoffee</h1>
            <p>Hệ thống quản lý quán cà phê</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/login" novalidate>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" class="form-control"
                       value="${email}" placeholder="admin@polycoffee.vn" required autofocus>
            </div>
            <div class="form-group">
                <label for="password">Mật khẩu</label>
                <input type="password" id="password" name="password" class="form-control"
                       placeholder="••••••" required>
            </div>
            <button type="submit" class="btn btn-primary btn-block">Đăng nhập</button>
        </form>
        <p class="login-hint">Demo: admin@polycoffee.vn / admin123</p>
    </div>
</div>
</body>
</html>
