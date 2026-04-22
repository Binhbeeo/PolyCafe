<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đơn hàng – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="../admin/_header.jsp" %>

<div class="page-header">
    <h2>🧾 Đơn hàng của tôi</h2>
    <a href="${pageContext.request.contextPath}/staff/bills?action=new" class="btn btn-primary">+ Tạo đơn mới</a>
</div>

<% if ("created".equals(request.getParameter("msg"))) { %>
<div class="alert alert-success">Tạo hóa đơn thành công!</div>
<% } else if ("finished".equals(request.getParameter("msg"))) { %>
<div class="alert alert-success">Đã chuyển sang thanh toán!</div>
<% } else if ("cancelled".equals(request.getParameter("msg"))) { %>
<div class="alert alert-warning">Đã hủy hóa đơn.</div>
<% } else if ("err_status".equals(request.getParameter("msg"))) { %>
<div class="alert alert-danger">Thao tác không hợp lệ hoặc bạn không có quyền thực hiện.</div>
<% } %>

<div class="card">
    <table class="table">
        <thead>
            <tr><th>Mã đơn</th><th>Ngày tạo</th><th>Tổng tiền</th><th>Trạng thái</th><th>Thao tác</th></tr>
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
            <td><%= b.getCreatedAt() != null ? sdf.format(b.getCreatedAt()) : "" %></td>
            <td><%= nf.format(b.getTotal()) %>đ</td>
            <td>
                <% if ("waiting".equals(b.getStatus())) { %><span class="badge orange">Đang chờ</span>
                <% } else if ("finish".equals(b.getStatus())) { %><span class="badge green">Đã thanh toán</span>
                <% } else { %><span class="badge gray">Đã hủy</span><% } %>
            </td>
            <td>
                <a href="${pageContext.request.contextPath}/staff/bills?action=detail&id=<%= b.getId() %>" class="btn btn-sm btn-outline">Chi tiết</a>
                <% if ("waiting".equals(b.getStatus())) { %>
                <a href="${pageContext.request.contextPath}/staff/bills?action=finish&id=<%= b.getId() %>"
                   class="btn btn-sm btn-primary"
                   onclick="return confirm('Xác nhận thanh toán hóa đơn này?')">Thanh toán</a>
                <a href="${pageContext.request.contextPath}/staff/bills?action=cancel&id=<%= b.getId() %>"
                   class="btn btn-sm btn-danger"
                   onclick="return confirm('Hủy hóa đơn này?')">Hủy</a>
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
