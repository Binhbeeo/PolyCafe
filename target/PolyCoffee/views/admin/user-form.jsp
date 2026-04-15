<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.polycoffee.entity.User" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Nhân viên – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="_header.jsp" %>

<%
    User editUser = (User) request.getAttribute("editUser");
    boolean isEdit = editUser != null;
%>

<div class="page-header">
    <h2><%= isEdit ? "✏️ Sửa tài khoản" : "➕ Thêm nhân viên" %></h2>
    <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline">← Quay lại</a>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-danger"><%= request.getAttribute("error") %></div>
<% } %>

<div class="card" style="max-width:520px">
    <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/admin/users">
            <input type="hidden" name="id" value="<%= isEdit ? editUser.getId() : 0 %>">

            <div class="form-group">
                <label>Email <span class="required">*</span></label>
                <input type="email" name="email" class="form-control"
                       value="<%= isEdit ? editUser.getEmail() : "" %>"
                       <%= isEdit ? "readonly" : "required" %>>
            </div>

            <% if (!isEdit) { %>
            <div class="form-group">
                <label>Mật khẩu <span class="required">*</span></label>
                <input type="password" name="password" class="form-control" required minlength="6" placeholder="Tối thiểu 6 ký tự">
            </div>
            <% } %>

            <div class="form-group">
                <label>Họ và tên <span class="required">*</span></label>
                <input type="text" name="fullName" class="form-control"
                       value="<%= isEdit ? editUser.getFullName() : "" %>" required>
            </div>

            <div class="form-group">
                <label>Số điện thoại</label>
                <input type="tel" name="phone" class="form-control"
                       value="<%= isEdit && editUser.getPhone() != null ? editUser.getPhone() : "" %>">
            </div>

            <div class="form-group">
                <label>Vai trò</label>
                <select name="role" class="form-control">
                    <option value="staff" <%= (isEdit && "staff".equals(editUser.getRole())) ? "selected" : "" %>>Nhân viên</option>
                    <option value="admin" <%= (isEdit && "admin".equals(editUser.getRole())) ? "selected" : "" %>>Quản lý</option>
                </select>
            </div>

            <% if (isEdit) { %>
            <div class="form-group">
                <label class="checkbox-label">
                    <input type="checkbox" name="active" value="true" <%= editUser.isActive() ? "checked" : "" %>>
                    Hoạt động
                </label>
            </div>
            <% } %>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">💾 Lưu</button>
                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline">Hủy</a>
            </div>
        </form>
    </div>
</div>

</main></div>
</body>
</html>
