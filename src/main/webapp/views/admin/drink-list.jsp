<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*,com.polycoffee.util.FileUtil" %>
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

<!-- Bộ lọc client-side -->
<div class="filter-bar">
    <input type="text" id="keyword" class="form-control"
           placeholder="🔍 Tìm tên đồ uống..." style="width:220px" autocomplete="off">
    <select id="categoryFilter" class="form-control" style="width:190px">
        <option value="0">-- Tất cả danh mục --</option>
        <%
            List<Category> cats = (List<Category>) request.getAttribute("categories");
            if (cats != null) for (Category c : cats) {
        %>
        <option value="<%= c.getId() %>"><%= c.getName() %></option>
        <% } %>
    </select>
</div>

<% if ("saved".equals(request.getParameter("msg"))) { %>
<div class="alert alert-success">Lưu thành công!</div>
<% } else if ("deleted".equals(request.getParameter("msg"))) { %>
<div class="alert alert-warning">Đã xóa đồ uống.</div>
<% } else if ("err_sold".equals(request.getParameter("msg"))) { %>
<div class="alert alert-danger">Không thể xóa đồ uống đã từng được bán.</div>
<% } %>

<div class="card">
    <table class="table">
        <thead>
        <tr><th>Ảnh</th><th>Tên</th><th>Danh mục</th><th>Giá</th><th>Trạng thái</th><th>Thao tác</th></tr>
        </thead>
        <tbody id="drinkTableBody">
        <%
            List<Drink> drinks = (List<Drink>) request.getAttribute("drinks");
            NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));
            if (drinks != null) for (Drink d : drinks) {
        %>
        <tr data-name="<%= d.getName().toLowerCase() %>"
            data-category="<%= d.getCategoryId() %>">
            <td>
                <img src="<%= FileUtil.getImageUrl(request, d.getImage()) %>" class="thumb" alt="">
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
    <div id="noResult" style="display:none;text-align:center;padding:24px;color:#aaa;">Không tìm thấy đồ uống nào</div>
</div>

<script>
    function filterDrinks() {
        var kw  = document.getElementById('keyword').value.toLowerCase().trim();
        var cat = document.getElementById('categoryFilter').value;
        var rows = document.querySelectorAll('#drinkTableBody tr');
        var found = 0;
        rows.forEach(function(row) {
            var nameMatch = row.getAttribute('data-name').indexOf(kw) >= 0;
            var catMatch  = cat === '0' || row.getAttribute('data-category') === cat;
            var show = nameMatch && catMatch;
            row.style.display = show ? '' : 'none';
            if (show) found++;
        });
        document.getElementById('noResult').style.display = found === 0 ? 'block' : 'none';
    }

    document.getElementById('keyword').addEventListener('input', filterDrinks);
    document.getElementById('categoryFilter').addEventListener('change', filterDrinks);
</script>

</main></div>
</body>
</html>
