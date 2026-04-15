<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,com.polycoffee.entity.Category" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Danh mục – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="_header.jsp" %>

<div class="page-header">
    <h2>🗂️ Quản lý danh mục</h2>
    <a href="${pageContext.request.contextPath}/admin/categories?action=add" class="btn btn-primary">+ Thêm mới</a>
</div>

<% if ("saved".equals(request.getParameter("msg"))) { %>
<div class="alert alert-success">Lưu thành công!</div>
<% } else if ("deleted".equals(request.getParameter("msg"))) { %>
<div class="alert alert-warning">Đã xóa danh mục.</div>
<% } %>

<div class="card">
    <table class="table">
        <thead><tr><th>ID</th><th>Tên danh mục</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
        <tbody>
        <%
            List<Category> cats = (List<Category>) request.getAttribute("categories");
            if (cats != null) for (Category c : cats) {
        %>
        <tr>
            <td><%= c.getId() %></td>
            <td><%= c.getName() %></td>
            <td>
                <% if (c.isActive()) { %><span class="badge green">Hoạt động</span>
                <% } else { %><span class="badge gray">Tạm ngừng</span><% } %>
            </td>
            <td>
                <a href="${pageContext.request.contextPath}/admin/categories?action=edit&id=<%= c.getId() %>" class="btn btn-sm btn-outline">Sửa</a>
                <a href="${pageContext.request.contextPath}/admin/categories?action=toggle&id=<%= c.getId() %>" class="btn btn-sm btn-warning">
                    <%= c.isActive() ? "Ngừng" : "Kích hoạt" %>
                </a>
                <a href="${pageContext.request.contextPath}/admin/categories?action=delete&id=<%= c.getId() %>"
                   class="btn btn-sm btn-danger"
                   onclick="return confirm('Xóa danh mục này?')">Xóa</a>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

</main></div>
</body>
</html>
