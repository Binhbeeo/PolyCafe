<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.polycoffee.entity.Category" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Danh mục – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="_header.jsp" %>

<%
    Category cat = (Category) request.getAttribute("category");
    boolean isEdit = cat != null;
%>

<div class="page-header">
    <h2><%= isEdit ? "✏️ Sửa danh mục" : "➕ Thêm danh mục" %></h2>
    <a href="${pageContext.request.contextPath}/admin/categories" class="btn btn-outline">← Quay lại</a>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-danger"><%= request.getAttribute("error") %></div>
<% } %>

<div class="card" style="max-width:500px">
    <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/admin/categories">
            <input type="hidden" name="id" value="<%= isEdit ? cat.getId() : 0 %>">

            <div class="form-group">
                <label>Tên danh mục <span class="required">*</span></label>
                <input type="text" name="name" class="form-control"
                       value="<%= isEdit ? cat.getName() : "" %>" required maxlength="100">
            </div>

            <div class="form-group">
                <label class="checkbox-label">
                    <input type="checkbox" name="active" value="true"
                           <%= (!isEdit || cat.isActive()) ? "checked" : "" %>>
                    Hoạt động
                </label>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">💾 Lưu</button>
                <a href="${pageContext.request.contextPath}/admin/categories" class="btn btn-outline">Hủy</a>
            </div>
        </form>
    </div>
</div>

</main></div>
</body>
</html>
