<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tạo đơn – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
<%@ include file="../admin/_header.jsp" %>

<div class="page-header">
    <h2>➕ Tạo hóa đơn mới</h2>
    <a href="${pageContext.request.contextPath}/staff/bills" class="btn btn-outline">← Quay lại</a>
</div>

<% if (request.getAttribute("error") != null) { %>
<div class="alert alert-danger"><%= request.getAttribute("error") %></div>
<% } %>

<%
    List<Drink> drinks = (List<Drink>) request.getAttribute("drinks");
    NumberFormat nf = NumberFormat.getInstance(new Locale("vi","VN"));
%>

<form method="post" action="${pageContext.request.contextPath}/staff/bills" id="billForm">
    <input type="hidden" name="action" value="create">

    <div class="bill-new-layout">
        <!-- Danh sách đồ uống -->
        <div class="card drinks-panel">
            <div class="card-header">🥤 Chọn đồ uống</div>
            <div class="card-body">
                <div class="drink-grid">
                    <% if (drinks != null) for (Drink d : drinks) { %>
                    <div class="drink-item"
                         data-id="<%= d.getId() %>"
                         data-name="<%= d.getName().replace("\"","&quot;") %>"
                         data-price="<%= (int) d.getPrice() %>">
                        <% if (d.getImage() != null && !d.getImage().isEmpty()) { %>
                        <img src="<%= d.getImage() %>" alt="">
                        <% } else { %>
                        <div class="drink-no-img">☕</div>
                        <% } %>
                        <div class="drink-name"><%= d.getName() %></div>
                        <div class="drink-price"><%= nf.format(d.getPrice()) %>đ</div>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Giỏ hàng -->
        <div class="card cart-panel">
            <div class="card-header">🛒 Giỏ hàng</div>
            <div class="card-body">
                <div id="emptyCart" class="empty-state">Chưa có đồ uống nào</div>
                <table class="table" id="cartTable" style="display:none">
                    <thead><tr><th>Tên</th><th>Giá</th><th>SL</th><th>Thành tiền</th><th></th></tr></thead>
                    <tbody id="cartBody"></tbody>
                    <tfoot>
                    <tr>
                        <td colspan="3" style="text-align:right"><strong>Tổng cộng:</strong></td>
                        <td colspan="2"><strong id="grandTotal">0đ</strong></td>
                    </tr>
                    </tfoot>
                </table>
                <div id="cartHiddenInputs"></div>
                <button type="submit" class="btn btn-primary btn-block mt-3" id="submitBtn" disabled>
                    💾 Tạo hóa đơn
                </button>
            </div>
        </div>
    </div>
</form>

<script>
    var cart = {};
    var nf = new Intl.NumberFormat('vi-VN');

    document.querySelectorAll('.drink-item').forEach(function(el) {
        el.addEventListener('click', function() {
            var id    = parseInt(this.getAttribute('data-id'));
            var name  = this.getAttribute('data-name');
            var price = parseInt(this.getAttribute('data-price'));
            addDrink(id, name, price);
        });
    });

    function addDrink(id, name, price) {
        if (cart[id]) {
            cart[id].qty++;
        } else {
            cart[id] = { name: name, price: price, qty: 1 };
        }
        renderCart();
    }

    function changeQty(id, delta) {
        if (!cart[id]) return;
        cart[id].qty += delta;
        if (cart[id].qty <= 0) delete cart[id];
        renderCart();
    }

    function removeItem(id) {
        delete cart[id];
        renderCart();
    }

    function renderCart() {
        var tbody        = document.getElementById('cartBody');
        var hiddenInputs = document.getElementById('cartHiddenInputs');
        var emptyCart    = document.getElementById('emptyCart');
        var cartTable    = document.getElementById('cartTable');
        var submitBtn    = document.getElementById('submitBtn');
        var grandTotal   = document.getElementById('grandTotal');

        tbody.innerHTML        = '';
        hiddenInputs.innerHTML = '';

        var total = 0;
        var count = 0;

        Object.keys(cart).forEach(function(id) {
            var item = cart[id];
            var sub  = item.price * item.qty;
            total += sub;
            count++;

            var tr = document.createElement('tr');

            // Tên
            var td1 = document.createElement('td');
            td1.textContent = item.name;

            // Giá
            var td2 = document.createElement('td');
            td2.textContent = nf.format(item.price) + 'đ';

            // Số lượng
            var td3 = document.createElement('td');
            var div = document.createElement('div');
            div.className = 'qty-control';

            var btnM = document.createElement('button');
            btnM.type = 'button';
            btnM.textContent = '−';
            btnM.setAttribute('data-id', id);
            btnM.addEventListener('click', function() { changeQty(parseInt(this.getAttribute('data-id')), -1); });

            var sp = document.createElement('span');
            sp.textContent = item.qty;

            var btnP = document.createElement('button');
            btnP.type = 'button';
            btnP.textContent = '+';
            btnP.setAttribute('data-id', id);
            btnP.addEventListener('click', function() { changeQty(parseInt(this.getAttribute('data-id')), 1); });

            div.appendChild(btnM);
            div.appendChild(sp);
            div.appendChild(btnP);
            td3.appendChild(div);

            // Thành tiền
            var td4 = document.createElement('td');
            td4.textContent = nf.format(sub) + 'đ';

            // Xóa
            var td5 = document.createElement('td');
            var btnD = document.createElement('button');
            btnD.type = 'button';
            btnD.className = 'btn btn-sm btn-danger';
            btnD.textContent = '✕';
            btnD.setAttribute('data-id', id);
            btnD.addEventListener('click', function() { removeItem(parseInt(this.getAttribute('data-id'))); });
            td5.appendChild(btnD);

            tr.appendChild(td1);
            tr.appendChild(td2);
            tr.appendChild(td3);
            tr.appendChild(td4);
            tr.appendChild(td5);
            tbody.appendChild(tr);

            // Hidden inputs để submit form
            var i1 = document.createElement('input');
            i1.type = 'hidden'; i1.name = 'drinkId[]'; i1.value = id;
            var i2 = document.createElement('input');
            i2.type = 'hidden'; i2.name = 'quantity[]'; i2.value = item.qty;
            hiddenInputs.appendChild(i1);
            hiddenInputs.appendChild(i2);
        });

        grandTotal.textContent     = nf.format(total) + 'đ';
        emptyCart.style.display    = count === 0 ? 'block' : 'none';
        cartTable.style.display    = count === 0 ? 'none'  : 'table';
        submitBtn.disabled         = count === 0;
    }
</script>
</main></div>
</body>
</html>
