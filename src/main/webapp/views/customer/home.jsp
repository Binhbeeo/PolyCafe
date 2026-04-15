<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PolyCoffee – Thực đơn</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="public-page">

<!-- Header -->
<header class="public-header">
    <div class="public-header-inner">
        <div class="brand">☕ <strong>PolyCoffee</strong></div>
        <nav class="public-nav">
            <a href="${pageContext.request.contextPath}/">Thực đơn</a>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary btn-sm">Đăng nhập</a>
        </nav>
    </div>
</header>

<!-- Hero -->
<section class="hero">
    <h1>Chào mừng đến với PolyCoffee</h1>
    <p>Khám phá menu đồ uống phong phú của chúng tôi</p>
</section>

<div class="public-container">

    <!-- Danh mục filter -->
    <%
        List<Category> categories = (List<Category>) request.getAttribute("categories");
        List<Drink>    drinks     = (List<Drink>)    request.getAttribute("drinks");
        int selectedCategory      = (request.getAttribute("selectedCategory") instanceof Integer) ? (Integer) request.getAttribute("selectedCategory") : 0;
        NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));
    %>
    <div class="category-tabs">
        <a href="${pageContext.request.contextPath}/"
           class="tab-btn <%= selectedCategory == 0 ? "active" : "" %>">Tất cả</a>
        <% if (categories != null) for (Category c : categories) { %>
        <a href="${pageContext.request.contextPath}/?category=<%= c.getId() %>"
           class="tab-btn <%= c.getId() == selectedCategory ? "active" : "" %>">
            <%= c.getName() %>
        </a>
        <% } %>
    </div>

    <!-- Lưới đồ uống -->
    <div class="menu-grid">
        <% if (drinks != null && !drinks.isEmpty()) {
               for (Drink d : drinks) { %>
        <div class="menu-card">
            <div class="menu-card-img">
                <% if (d.getImage() != null && !d.getImage().isEmpty()) { %>
                <img src="<%= d.getImage() %>" alt="<%= d.getName() %>">
                <% } else { %>
                <div class="menu-no-img">☕</div>
                <% } %>
            </div>
            <div class="menu-card-body">
                <div class="menu-category"><%= d.getCategoryName() != null ? d.getCategoryName() : "" %></div>
                <h3 class="menu-name"><%= d.getName() %></h3>
                <% if (d.getDescription() != null && !d.getDescription().isEmpty()) { %>
                <p class="menu-desc"><%= d.getDescription() %></p>
                <% } %>
                <div class="menu-price"><%= nf.format(d.getPrice()) %>đ</div>
            </div>
        </div>
        <% }
           } else { %>
        <div class="empty-state" style="grid-column:1/-1">Không có đồ uống nào.</div>
        <% } %>
    </div>
</div>

<footer class="public-footer">
    <p>© 2024 PolyCoffee – FPT Polytechnic</p>
</footer>
</body>
</html>
