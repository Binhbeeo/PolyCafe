<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết hóa đơn – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="_header.jsp" %>

<%
    Bill bill = (Bill) request.getAttribute("bill");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));
%>

<div class="page-header">
    <h2>🧾 Chi tiết hóa đơn: <%= bill.getCode() %></h2>
    <a href="${pageContext.request.contextPath}/admin/bills" class="btn btn-outline">← Quay lại</a>
</div>

<div class="detail-meta">
    <span>👤 Nhân viên: <strong><%= bill.getUserFullName() %></strong></span>
    <span>📅 Ngày tạo: <strong><%= bill.getCreatedAt() != null ? sdf.format(bill.getCreatedAt()) : "" %></strong></span>
    <span>Trạng thái:
        <% if ("waiting".equals(bill.getStatus())) { %><span class="badge orange">Đang chờ</span>
        <% } else if ("finish".equals(bill.getStatus())) { %><span class="badge green">Đã thanh toán</span>
        <% } else { %><span class="badge gray">Đã hủy</span><% } %>
    </span>
</div>

<div class="card">
    <table class="table">
        <thead><tr><th>Đồ uống</th><th>Đơn giá</th><th>SL</th><th>Thành tiền</th></tr></thead>
        <tbody>
        <%
            List<BillDetail> details = bill.getDetails();
            if (details != null) for (BillDetail d : details) {
        %>
        <tr>
            <td><%= d.getDrinkName() %></td>
            <td><%= nf.format(d.getPrice()) %>đ</td>
            <td><%= d.getQuantity() %></td>
            <td><%= nf.format(d.getSubTotal()) %>đ</td>
        </tr>
        <% } %>
        </tbody>
        <tfoot>
            <tr><td colspan="3" style="text-align:right"><strong>Tổng cộng:</strong></td>
                <td><strong><%= nf.format(bill.getTotal()) %>đ</strong></td></tr>
        </tfoot>
    </table>
</div>

<% if ("finish".equals(bill.getStatus())) { %>
<a href="${pageContext.request.contextPath}/admin/bills?action=cancel&id=<%= bill.getId() %>"
   class="btn btn-danger"
   onclick="return confirm('Hủy hóa đơn đã thanh toán?')">Hủy hóa đơn</a>
<% } %>

</main></div>
</body>
</html>
