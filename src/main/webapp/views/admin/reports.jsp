<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Báo cáo – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
<%@ include file="_header.jsp" %>

<div class="page-header">
    <h2>📈 Báo cáo & Thống kê</h2>
</div>

<!-- Bộ lọc thời gian -->
<form method="get" action="${pageContext.request.contextPath}/admin/reports" class="filter-bar">
    <label>Từ ngày:</label>
    <input type="date" name="from" class="form-control" value="${from}">
    <label>Đến ngày:</label>
    <input type="date" name="to" class="form-control" value="${to}">
    <button type="submit" class="btn btn-primary">🔍 Xem báo cáo</button>
</form>

<%
    List<Map<String,Object>> revenueByDay = (List<Map<String,Object>>) request.getAttribute("revenueByDay");
    List<Map<String,Object>> topDrinks   = (List<Map<String,Object>>) request.getAttribute("topDrinks");
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));

    // Build chart data
    StringBuilder labels   = new StringBuilder("[");
    StringBuilder revenues = new StringBuilder("[");
    if (revenueByDay != null) {
        for (int i = 0; i < revenueByDay.size(); i++) {
            Map<String,Object> r = revenueByDay.get(i);
            if (i > 0) { labels.append(","); revenues.append(","); }
            labels.append("'").append(r.get("date")).append("'");
            revenues.append(r.get("revenue"));
        }
    }
    labels.append("]");
    revenues.append("]");

    StringBuilder drinkLabels   = new StringBuilder("[");
    StringBuilder drinkQuantity = new StringBuilder("[");
    if (topDrinks != null) {
        for (int i = 0; i < topDrinks.size(); i++) {
            Map<String,Object> t = topDrinks.get(i);
            if (i > 0) { drinkLabels.append(","); drinkQuantity.append(","); }
            drinkLabels.append("'").append(t.get("name")).append("'");
            drinkQuantity.append(t.get("totalSold"));
        }
    }
    drinkLabels.append("]");
    drinkQuantity.append("]");
%>

<div class="report-grid">
    <!-- Biểu đồ doanh thu -->
    <div class="card">
        <div class="card-header">💰 Doanh thu theo ngày</div>
        <div class="card-body">
            <canvas id="revenueChart" height="200"></canvas>
        </div>
    </div>

    <!-- Biểu đồ top sản phẩm -->
    <div class="card">
        <div class="card-header">🏆 Top sản phẩm bán chạy</div>
        <div class="card-body">
            <canvas id="topDrinkChart" height="200"></canvas>
        </div>
    </div>
</div>

<!-- Bảng doanh thu -->
<div class="card mt-4">
    <div class="card-header">📋 Chi tiết doanh thu</div>
    <table class="table">
        <thead><tr><th>Ngày</th><th>Số hóa đơn</th><th>Doanh thu</th></tr></thead>
        <tbody>
        <% if (revenueByDay != null) for (Map<String,Object> r : revenueByDay) { %>
        <tr>
            <td><%= r.get("date") %></td>
            <td><%= r.get("totalBills") %></td>
            <td><%= nf.format(r.get("revenue")) %>đ</td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- Bảng top drinks -->
<div class="card mt-4">
    <div class="card-header">🥤 Chi tiết top sản phẩm</div>
    <table class="table">
        <thead><tr><th>#</th><th>Tên</th><th>Danh mục</th><th>Đã bán</th><th>Doanh thu</th></tr></thead>
        <tbody>
        <%
            if (topDrinks != null) {
                int rank = 1;
                for (Map<String,Object> t : topDrinks) {
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

<script>
// Biểu đồ doanh thu
new Chart(document.getElementById('revenueChart'), {
    type: 'bar',
    data: {
        labels: <%= labels %>,
        datasets: [{
            label: 'Doanh thu (đ)',
            data: <%= revenues %>,
            backgroundColor: 'rgba(99,179,237,0.6)',
            borderColor: '#4299e1',
            borderWidth: 1
        }]
    },
    options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: { y: { beginAtZero: true } }
    }
});

// Biểu đồ top drinks
new Chart(document.getElementById('topDrinkChart'), {
    type: 'doughnut',
    data: {
        labels: <%= drinkLabels %>,
        datasets: [{
            data: <%= drinkQuantity %>,
            backgroundColor: ['#fc8181','#f6ad55','#68d391','#63b3ed','#b794f4',
                              '#f687b3','#76e4f7','#fbd38d','#9ae6b4','#90cdf4']
        }]
    },
    options: { responsive: true }
});
</script>

</main></div>
</body>
</html>
