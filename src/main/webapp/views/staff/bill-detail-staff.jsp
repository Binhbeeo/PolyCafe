<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*,com.polycoffee.util.FileUtil" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết đơn – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="../admin/_header.jsp" %>

<%
    Bill bill = (Bill) request.getAttribute("bill");
    List<Drink> allDrinks = (List<Drink>) request.getAttribute("allDrinks");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));
    boolean isWaiting = "waiting".equals(bill.getStatus());
%>

<div class="page-header">
    <h2>🧾 Chi tiết đơn: <%= bill.getCode() %></h2>
    <a href="${pageContext.request.contextPath}/staff/bills" class="btn btn-outline">← Quay lại</a>
</div>

<div class="detail-meta">
    <span>📅 Ngày tạo: <strong><%= bill.getCreatedAt() != null ? sdf.format(bill.getCreatedAt()) : "" %></strong></span>
    <span>Trạng thái:
        <% if ("waiting".equals(bill.getStatus())) { %><span class="badge orange">Đang chờ</span>
        <% } else if ("finish".equals(bill.getStatus())) { %><span class="badge green">Đã thanh toán</span>
        <% } else { %><span class="badge gray">Đã hủy</span><% } %>
    </span>
</div>

<div class="card">
    <table class="table">
        <thead><tr><th>Đồ uống</th><th>Đơn giá</th><th>Số lượng</th><th>Thành tiền</th>
            <% if (isWaiting) { %><th>Sửa SL</th><% } %>
        </tr></thead>
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
            <% if (isWaiting) { %>
            <td>
                <form method="post" action="${pageContext.request.contextPath}/staff/bills" style="display:inline-flex;gap:4px">
                    <input type="hidden" name="action" value="updateQty">
                    <input type="hidden" name="billId" value="<%= bill.getId() %>">
                    <input type="hidden" name="drinkId" value="<%= d.getDrinkId() %>">
                    <input type="number" name="quantity" value="<%= d.getQuantity() %>" min="0" class="form-control" style="width:60px">
                    <button type="submit" class="btn btn-sm btn-primary">✓</button>
                </form>
            </td>
            <% } %>
        </tr>
        <% } %>
        </tbody>
        <tfoot>
            <tr>
                <td colspan="<%= isWaiting ? 4 : 3 %>" style="text-align:right"><strong>Tổng cộng:</strong></td>
                <td><strong><%= nf.format(bill.getTotal()) %>đ</strong></td>
                <% if (isWaiting) { %><td></td><% } %>
            </tr>
        </tfoot>
    </table>
</div>

<% if (isWaiting) { %>

<%-- Panel thêm đồ uống vào phiếu đang mở --%>
<div class="card mt-4">
    <div class="card-header">➕ Thêm đồ uống vào phiếu</div>
    <div class="card-body">
        <% if (allDrinks != null && !allDrinks.isEmpty()) { %>
        <div class="drink-grid">
            <% for (Drink d : allDrinks) { %>
            <a href="${pageContext.request.contextPath}/staff/bills?action=addDrink&billId=<%= bill.getId() %>&drinkId=<%= d.getId() %>"
               class="drink-item"
               onclick="return confirm('Thêm <%= d.getName() %> vào phiếu?')">
                <img src="<%= FileUtil.getImageUrl(request, d.getImage()) %>" alt="">
                <div class="drink-name"><%= d.getName() %></div>
                <div class="drink-price"><%= nf.format(d.getPrice()) %>đ</div>
            </a>
            <% } %>
        </div>
        <% } %>
    </div>
</div>

<div class="mt-3" style="display:flex;gap:12px">
    <a href="${pageContext.request.contextPath}/staff/bills?action=finish&id=<%= bill.getId() %>"
       class="btn btn-primary"
       onclick="return confirm('Xác nhận thanh toán?')">💳 Thanh toán</a>
    <a href="${pageContext.request.contextPath}/staff/bills?action=cancel&id=<%= bill.getId() %>"
       class="btn btn-danger"
       onclick="return confirm('Hủy hóa đơn này?')">✕ Hủy đơn</a>
</div>
<% } %>

</main></div>
</body>
</html>
