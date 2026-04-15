<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Hóa đơn – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="_header.jsp" %>

<div class="page-header">
    <h2>🧾 Quản lý hóa đơn</h2>
</div>

<!-- Filter by status -->
<div class="filter-bar">
    <a href="${pageContext.request.contextPath}/admin/bills" class="btn btn-sm ${empty param.status ? 'btn-primary' : 'btn-outline'}">Tất cả</a>
    <a href="${pageContext.request.contextPath}/admin/bills?status=waiting" class="btn btn-sm ${param.status == 'waiting' ? 'btn-primary' : 'btn-outline'}">Đang chờ</a>
    <a href="${pageContext.request.contextPath}/admin/bills?status=finish" class="btn btn-sm ${param.status == 'finish' ? 'btn-primary' : 'btn-outline'}">Đã thanh toán</a>
    <a href="${pageContext.request.contextPath}/admin/bills?status=cancel" class="btn btn-sm ${param.status == 'cancel' ? 'btn-primary' : 'btn-outline'}">Đã hủy</a>
</div>

<div class="card">
    <table class="table">
        <thead>
            <tr><th>Mã đơn</th><th>Nhân viên</th><th>Ngày tạo</th><th>Tổng tiền</th><th>Trạng thái</th><th>Thao tác</th></tr>
        </thead>
        <tbody>
        <%
            List<Bill> bills = (List<Bill>) request.getAttribute("bills");
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));
            if (bills != null) for (Bill b : bills) {
        %>
        <tr>
            <td><strong><%= b.getCode() %></strong></td>
            <td><%= b.getUserFullName() != null ? b.getUserFullName() : "" %></td>
            <td><%= b.getCreatedAt() != null ? sdf.format(b.getCreatedAt()) : "" %></td>
            <td><%= nf.format(b.getTotal()) %>đ</td>
            <td>
                <% if ("waiting".equals(b.getStatus())) { %><span class="badge orange">Đang chờ</span>
                <% } else if ("finish".equals(b.getStatus())) { %><span class="badge green">Đã thanh toán</span>
                <% } else { %><span class="badge gray">Đã hủy</span><% } %>
            </td>
            <td>
                <a href="${pageContext.request.contextPath}/admin/bills?action=detail&id=<%= b.getId() %>" class="btn btn-sm btn-outline">Chi tiết</a>
                <% if ("finish".equals(b.getStatus())) { %>
                <a href="${pageContext.request.contextPath}/admin/bills?action=cancel&id=<%= b.getId() %>"
                   class="btn btn-sm btn-danger"
                   onclick="return confirm('Hủy hóa đơn đã thanh toán?')">Hủy</a>
                <% } %>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

</main></div>
</body>
</html>
