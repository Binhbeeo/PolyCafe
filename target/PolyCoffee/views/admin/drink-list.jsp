<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đồ uống – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="_header.jsp" %>

<div class="page-header">
    <h2>🥤 Quản lý đồ uống</h2>
    <a href="${pageContext.request.contextPath}/admin/drinks?action=add" class="btn btn-primary">+ Thêm mới</a>
</div>

<!-- Bộ lọc -->
<form method="get" action="${pageContext.request.contextPath}/admin/drinks" class="filter-bar">
    <input type="text" name="keyword" class="form-control" placeholder="Tìm tên đồ uống..."
           value="${keyword}" style="width:200px">
    <select name="categoryId" class="form-control" style="width:160px">
        <option value="0">-- Tất cả danh mục --</option>
        <%
            List<Category> cats = (List<Category>) request.getAttribute("categories");
            int selCatId = (request.getAttribute("categoryId") instanceof Integer) ? (Integer) request.getAttribute("categoryId") : 0;
            if (cats != null) for (Category c : cats) {
        %>
        <option value="<%= c.getId() %>" <%= c.getId() == selCatId ? "selected" : "" %>><%= c.getName() %></option>
        <% } %>
    </select>
    <button type="submit" class="btn btn-primary">🔍 Lọc</button>
</form>

<% if ("saved".equals(request.getParameter("msg"))) { %>
<div class="alert alert-success">Lưu thành công!</div>
<% } %>

<div class="card">
    <table class="table">
        <thead>
            <tr><th>Ảnh</th><th>Tên</th><th>Danh mục</th><th>Giá</th><th>Trạng thái</th><th>Thao tác</th></tr>
        </thead>
        <tbody>
        <%
            List<Drink> drinks = (List<Drink>) request.getAttribute("drinks");
            NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));
            if (drinks != null) for (Drink d : drinks) {
        %>
        <tr>
            <td>
                <% if (d.getImage() != null && !d.getImage().isEmpty()) { %>
                <img src="<%= d.getImage() %>" class="thumb" alt="">
                <% } else { %>
                <span class="no-img">N/A</span>
                <% } %>
            </td>
            <td><%= d.getName() %></td>
            <td><%= d.getCategoryName() != null ? d.getCategoryName() : "" %></td>
            <td><%= nf.format(d.getPrice()) %>đ</td>
            <td>
                <% if (d.isActive()) { %><span class="badge green">Đang bán</span>
                <% } else { %><span class="badge gray">Ngừng bán</span><% } %>
            </td>
            <td>
                <a href="${pageContext.request.contextPath}/admin/drinks?action=edit&id=<%= d.getId() %>" class="btn btn-sm btn-outline">Sửa</a>
                <a href="${pageContext.request.contextPath}/admin/drinks?action=toggle&id=<%= d.getId() %>" class="btn btn-sm btn-warning">
                    <%= d.isActive() ? "Ngừng" : "Kích hoạt" %>
                </a>
                <a href="${pageContext.request.contextPath}/admin/drinks?action=delete&id=<%= d.getId() %>"
                   class="btn btn-sm btn-danger"
                   onclick="return confirm('Xóa đồ uống này?')">Xóa</a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

</main></div>
</body>
</html>
