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

<%
    Integer nextId = (Integer) request.getAttribute("nextId");
    Integer prevId = (Integer) request.getAttribute("prevId");
    String msg = request.getParameter("msg");
%>

<div class="page-header">
    <h2><%= isEdit ? "✏️ Sửa đồ uống" : "➕ Thêm đồ uống" %></h2>
    <div class="page-header-actions">
        <% if (isEdit) { %>
            <% if (prevId != null) { %>
                <a href="${pageContext.request.contextPath}/admin/drinks?action=edit&id=<%= prevId %>" class="btn btn-outline">⏮️ Trước</a>
            <% } %>
            <% if (nextId != null) { %>
                <a href="${pageContext.request.contextPath}/admin/drinks?action=edit&id=<%= nextId %>" class="btn btn-outline">Kế tiếp ⏭️</a>
            <% } %>
        <% } %>
        <a href="${pageContext.request.contextPath}/admin/drinks" class="btn btn-outline">← Danh sách</a>
    </div>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-danger"><%= request.getAttribute("error") %></div>
<% } %>

<% if ("saved".equals(msg)) { %>
<div class="alert alert-success">✅ Đã lưu thay đổi thành công!</div>
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
                <label>Hình ảnh (Chọn từ máy hoặc nhập URL)</label>
                
                <div style="margin-bottom: 10px;">
                    <small style="color: #666;">Cách 1: Chọn ảnh từ máy (Tự động tải lên ImgBB)</small>
                    <input type="file" name="imageFile" class="form-control" accept="image/*">
                </div>

                <div>
                    <small style="color: #666;">Cách 2: Hoặc dán Link ảnh (URL) trực tiếp</small>
                    <input type="text" name="imageUrl" class="form-control" 
                           placeholder="Dán link ảnh từ ImgBB, Google... vào đây"
                           value="<%= isEdit && drink.getImage() != null ? drink.getImage() : "" %>">
                </div>

                <% if (isEdit && drink.getImage() != null && !drink.getImage().isEmpty()) { %>
                <div class="current-image" style="margin-top: 10px;">
                    <img src="<%= FileUtil.getImageUrl(request, drink.getImage()) %>" alt="Ảnh hiện tại" style="height:80px;border-radius:8px;border: 1px solid #ddd;">
                    <small style="display: block; color: #888;">Ảnh hiện tại</small>
                </div>
                <% } %>
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
