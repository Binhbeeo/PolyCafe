<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tổng quan – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="_header.jsp" %>

<div class="page-header">
    <h2>📊 Tổng quan</h2>
</div>

<%
    double todayRevenue = (double) request.getAttribute("todayRevenue");
    double monthRevenue = (double) request.getAttribute("monthRevenue");
    int totalDrinks     = (int)    request.getAttribute("totalDrinks");
    int totalStaff      = (int)    request.getAttribute("totalStaff");
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));
%>

<div class="stats-grid">
    <div class="stat-card blue">
        <div class="stat-icon">💰</div>
        <div class="stat-info">
            <div class="stat-value"><%= nf.format(todayRevenue) %>đ</div>
            <div class="stat-label">Doanh thu hôm nay</div>
        </div>
    </div>
    <div class="stat-card green">
        <div class="stat-icon">📅</div>
        <div class="stat-info">
            <div class="stat-value"><%= nf.format(monthRevenue) %>đ</div>
            <div class="stat-label">Doanh thu tháng này</div>
        </div>
    </div>
    <div class="stat-card orange">
        <div class="stat-icon">🥤</div>
        <div class="stat-info">
            <div class="stat-value"><%= totalDrinks %></div>
            <div class="stat-label">Tổng đồ uống</div>
        </div>
    </div>
    <div class="stat-card purple">
        <div class="stat-icon">👥</div>
        <div class="stat-info">
            <div class="stat-value"><%= totalStaff %></div>
            <div class="stat-label">Nhân viên</div>
        </div>
    </div>
</div>

<div class="card mt-4">
    <div class="card-header">🏆 Top 5 sản phẩm bán chạy</div>
    <div class="card-body">
        <table class="table">
            <thead>
                <tr><th>#</th><th>Tên đồ uống</th><th>Danh mục</th><th>Đã bán</th><th>Doanh thu</th></tr>
            </thead>
            <tbody>
            <%
                List<Map<String,Object>> tops = (List<Map<String,Object>>) request.getAttribute("topDrinks");
                if (tops != null) {
                    int rank = 1;
                    for (Map<String,Object> t : tops) {
            %>
                <tr>
                    <td><%= rank++ %></td>
                    <td><%= t.get("name") %></td>
                    <td><%= t.get("categoryName") %></td>
                    <td><%= t.get("totalSold") %></td>
                    <td><%= nf.format(t.get("totalRevenue")) %>đ</td>
                </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</div>

</main></div>
</body>
</html>
