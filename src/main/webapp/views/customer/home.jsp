<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*,com.polycoffee.util.FileUtil" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PolyCoffee – Thực đơn</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="public-page">

<!-- Header -->
<header class="public-header">
    <div class="public-header-inner">
        <div class="brand">
            <i class="bi bi-cup-hot"></i>
            <strong>PolyCoffee</strong>
        </div>
        <nav class="public-nav">
            <a href="${pageContext.request.contextPath}/">
                <i class="bi bi-house"></i> Thực đơn
            </a>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-sm" style="background: rgba(255,255,255,0.2); color: #fff; border: 1px solid rgba(255,255,255,0.3);">
                <i class="bi bi-box-arrow-in-right"></i> Đăng nhập
            </a>
        </nav>
    </div>
</header>

<!-- Hero Section -->
<section class="hero">
    <h1><i class="bi bi-cup-hot"></i> Chào mừng đến với PolyCoffee</h1>
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
    
    <div style="margin-bottom: 28px;">
        <h3 style="margin-bottom: 16px; font-size: 18px; font-weight: 600; color: #2d3748;">
            <i class="bi bi-filter"></i> Danh mục
        </h3>
        <div class="category-tabs">
            <a href="${pageContext.request.contextPath}/"
               class="tab-btn <%= selectedCategory == 0 ? "active" : "" %>">
                <i class="bi bi-collection"></i> Tất cả
            </a>
            <% if (categories != null) for (Category c : categories) { %>
            <a href="${pageContext.request.contextPath}/?category=<%= c.getId() %>"
               class="tab-btn <%= c.getId() == selectedCategory ? "active" : "" %>">
                <%= c.getName() %>
            </a>
            <% } %>
        </div>
    </div>

    <!-- Lưới đồ uống -->
    <div style="margin-bottom: 28px;">
        <h3 style="margin-bottom: 20px; font-size: 18px; font-weight: 600; color: #2d3748;">
            <i class="bi bi-cup"></i> Menu đồ uống
        </h3>
        <% if (drinks != null && !drinks.isEmpty()) { %>
        <div class="menu-grid">
            <% for (Drink d : drinks) { %>
            <div class="menu-card fade-in">
                <div class="menu-card-img">
                    <img src="<%= FileUtil.getImageUrl(request, d.getImage()) %>" alt="<%= d.getName() %>" loading="lazy">
                </div>
                <div class="menu-card-body">
                    <div class="menu-category">
                        <i class="bi bi-tag"></i> <%= d.getCategoryName() != null ? d.getCategoryName() : "Khác" %>
                    </div>
                    <h3 class="menu-name"><%= d.getName() %></h3>
                    <% if (d.getDescription() != null && !d.getDescription().isEmpty()) { %>
                    <p class="menu-desc"><%= d.getDescription() %></p>
                    <% } %>
                    <div class="menu-price">
                        <i class="bi bi-currency-dollar"></i> <%= nf.format(d.getPrice()) %>đ
                    </div>
                </div>
            </div>
            <% } %>
        </div>
        <% } else { %>
        <div class="empty-state">
            <i class="bi bi-inbox" style="font-size: 48px; color: #ccc; display: block; margin-bottom: 12px;"></i>
            <p>Không có đồ uống nào.</p>
        </div>
        <% } %>
    </div>
</div>

<footer class="public-footer">
    <p>
        <i class="bi bi-c-circle"></i> 2024 PolyCoffee – FPT Polytechnic
    </p>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
