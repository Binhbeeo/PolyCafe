<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,com.polycoffee.entity.*,com.polycoffee.util.FileUtil" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đồ uống – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="_header.jsp" %>

<%
    Drink drink = (Drink) request.getAttribute("drink");
    boolean isEdit = drink != null;
    List<Category> categories = (List<Category>) request.getAttribute("categories");
%>

<div class="page-header">
    <h2><%= isEdit ? "✏️ Sửa đồ uống" : "➕ Thêm đồ uống" %></h2>
    <a href="${pageContext.request.contextPath}/admin/drinks" class="btn btn-outline">← Quay lại</a>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-danger"><%= request.getAttribute("error") %></div>
<% } %>

<div class="card" style="max-width:600px">
    <div class="card-body">
        <form method="post" action="${pageContext.request.contextPath}/admin/drinks"
              enctype="multipart/form-data">
            <input type="hidden" name="id" value="<%= isEdit ? drink.getId() : 0 %>">

            <div class="form-group">
                <label>Danh mục <span class="required">*</span></label>
                <select name="categoryId" class="form-control" required>
                    <option value="">-- Chọn danh mục --</option>
                    <% if (categories != null) for (Category c : categories) { %>
                    <option value="<%= c.getId() %>"
                        <%= (isEdit && drink.getCategoryId() == c.getId()) ? "selected" : "" %>>
                        <%= c.getName() %>
                    </option>
                    <% } %>
                </select>
            </div>

            <div class="form-group">
                <label>Tên đồ uống <span class="required">*</span></label>
                <input type="text" name="name" class="form-control"
                       value="<%= isEdit ? drink.getName() : "" %>" required maxlength="200">
            </div>

            <div class="form-group">
                <label>Giá (VNĐ) <span class="required">*</span></label>
                <input type="number" name="price" class="form-control"
                       value="<%= isEdit ? (int) drink.getPrice() : "" %>" min="0" step="500" required>
            </div>

            <div class="form-group">
                <label>Mô tả</label>
                <textarea name="description" class="form-control" rows="3"><%= isEdit && drink.getDescription() != null ? drink.getDescription() : "" %></textarea>
            </div>

            <div class="form-group">
                <label>Hình ảnh</label>
                <% if (isEdit) { %>
                <div class="current-image">
                    <img src="<%= FileUtil.getImageUrl(request, drink.getImage()) %>" alt="Ảnh hiện tại" style="height:80px;border-radius:8px">
                    <small>Chọn ảnh mới để thay thế</small>
                </div>
                <% } %>
                <input type="file" name="image" class="form-control" accept="image/*">
            </div>

            <div class="form-group">
                <label class="checkbox-label">
                    <input type="checkbox" name="active" value="true"
                           <%= (!isEdit || drink.isActive()) ? "checked" : "" %>>
                    Đang bán
                </label>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">💾 Lưu</button>
                <a href="${pageContext.request.contextPath}/admin/drinks" class="btn btn-outline">Hủy</a>
            </div>
        </form>
    </div>
</div>

</main></div>
</body>
</html>
