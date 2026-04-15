<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.polycoffee.util.AuthUtil" %>
<%
    // Nếu đã login rồi thì không cho vào trang login nữa
    if (AuthUtil.isAuthenticated(request)) {
        if (AuthUtil.isManager(request)) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/staff/bills");
        }
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập – PolyCoffee</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        body.login-page {
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #6f4e37 0%, #3d2b1f 100%);
        }
        .login-wrapper {
            width: 100%;
            max-width: 420px;
            padding: 20px;
        }
        .login-card {
            background: #fff;
            border-radius: 16px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        .login-logo {
            text-align: center;
            margin-bottom: 32px;
        }
        .login-logo i {
            font-size: 52px;
            color: #6f4e37;
            display: block;
            margin-bottom: 12px;
        }
        .login-logo h1 {
            font-size: 28px;
            color: #6f4e37;
            margin: 0;
            font-weight: 700;
        }
        .login-logo p {
            color: #888;
            font-size: 13px;
            margin-top: 6px;
        }
        .login-form {
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 18px;
        }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 500;
            font-size: 14px;
            color: #2d3748;
        }
        .form-control {
            width: 100%;
            padding: 10px 14px;
            border: 1.5px solid #d1c7bc;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.2s ease;
        }
        .form-control:focus {
            outline: none;
            border-color: #6f4e37;
            box-shadow: 0 0 0 3px rgba(111, 78, 55, 0.1);
        }
        .btn-login {
            width: 100%;
            padding: 10px;
            background: #6f4e37;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn-login:hover {
            background: #5a3d29;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(111, 78, 55, 0.3);
        }
        .btn-home {
            width: 100%;
            padding: 10px;
            background: transparent;
            color: #6f4e37;
            border: 1.5px solid #6f4e37;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
            margin-top: 10px;
        }
        .btn-home:hover {
            background: #6f4e37;
            color: #fff;
        }
        .login-hint {
            text-align: center;
            margin-top: 16px;
            color: #999;
            font-size: 12px;
        }
        .alert {
            padding: 12px 14px;
            border-radius: 8px;
            margin-bottom: 16px;
            font-size: 14px;
            border-left: 4px solid;
        }
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border-left-color: #dc3545;
        }
    </style>
</head>
<body class="login-page">
<div class="login-wrapper">
    <div class="login-card">
        <div class="login-logo">
            <i class="bi bi-cup-hot"></i>
            <h1>PolyCoffee</h1>
            <p>Hệ thống quản lý quán cà phê</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
        <div class="alert alert-danger">
            <i class="bi bi-exclamation-circle"></i>
            <%= request.getAttribute("error") %>
        </div>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/login" class="login-form" novalidate>
            <div class="form-group">
                <label for="email">
                    <i class="bi bi-envelope"></i> Email
                </label>
                <input type="email" id="email" name="email" class="form-control"
                       value="${email}" placeholder="admin@polycoffee.vn" required autofocus>
            </div>
            <div class="form-group">
                <label for="password">
                    <i class="bi bi-lock"></i> Mật khẩu
                </label>
                <input type="password" id="password" name="password" class="form-control"
                       placeholder="••••••" required>
            </div>
            <button type="submit" class="btn-login">
                <i class="bi bi-box-arrow-in-right"></i> Đăng nhập
            </button>
        </form>

        <a href="${pageContext.request.contextPath}/" class="btn-home">
            <i class="bi bi-house"></i> Về trang chủ
        </a>

        <p class="login-hint">
            <i class="bi bi-info-circle"></i> Demo: admin@polycoffee.vn / admin123
        </p>
    </div>
</div>
</body>
</html>
