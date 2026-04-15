<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,java.text.*,com.polycoffee.entity.*,com.polycoffee.util.FileUtil" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Tạo đơn – PolyCoffee</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .cart-item { display:flex; align-items:center; gap:8px; padding:8px 0; border-bottom:1px solid #f0ebe4; }
        .cart-item-name  { flex:1; font-weight:600; font-size:13px; min-width:0; word-break:break-word; }
        .cart-item-price { font-size:12px; color:#888; white-space:nowrap; }
        .cart-item-qty   { display:flex; align-items:center; gap:4px; flex-shrink:0; }
        .cart-item-qty button {
            width:26px; height:26px; border:1.5px solid #d1c7bc;
            background:#fff; border-radius:6px; cursor:pointer;
            font-size:14px; font-weight:700; line-height:1; flex-shrink:0;
        }
        .cart-item-qty button:hover { background:#f5f0eb; }
        .cart-item-qty span { min-width:22px; text-align:center; font-weight:600; font-size:13px; }
        .cart-item-sub { font-size:13px; font-weight:700; color:var(--primary); white-space:nowrap; min-width:70px; text-align:right; }
        .btn-remove {
            width:26px; height:26px; border:none; background:#fed7d7; color:#c53030;
            border-radius:6px; cursor:pointer; font-size:13px; font-weight:700;
            flex-shrink:0; display:flex; align-items:center; justify-content:center;
        }
        .btn-remove:hover { background:#fc8181; color:#fff; }
        .cart-total { display:flex; justify-content:space-between; padding:10px 0 0; font-size:15px; font-weight:700; border-top:2px solid #e2d9d0; margin-top:4px; }

        /* Search bar trong drinks panel */
        .drink-search { width:100%; padding:8px 12px; border:1.5px solid #d1c7bc; border-radius:8px; font-size:13.5px; margin-bottom:14px; box-sizing:border-box; }
        .drink-search:focus { outline:none; border-color:var(--primary); }
        .drink-item.hidden { display:none; }
        .no-result { text-align:center; color:#aaa; padding:24px; display:none; }
    </style>
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
                <input type="text" id="drinkSearch" class="drink-search" placeholder="🔍 Tìm tên đồ uống..." autocomplete="off">
                <div class="drink-grid" id="drinkGrid">
                    <% if (drinks != null) for (Drink d : drinks) { %>
                    <div class="drink-item"
                         data-id="<%= d.getId() %>"
                         data-name="<%= d.getName().replace("\"","&quot;") %>"
                         data-price="<%= (int) d.getPrice() %>"
                         data-search="<%= d.getName().toLowerCase() %>">
                        <img src="<%= FileUtil.getImageUrl(request, d.getImage()) %>" alt="">
                        <div class="drink-name"><%= d.getName() %></div>
                        <div class="drink-price"><%= nf.format(d.getPrice()) %>đ</div>
                    </div>
                    <% } %>
                </div>
                <div class="no-result" id="noResult">Không tìm thấy đồ uống nào</div>
            </div>
        </div>

        <!-- Giỏ hàng -->
        <div class="card cart-panel">
            <div class="card-header">🛒 Giỏ hàng</div>
            <div class="card-body">
                <div id="emptyCart" class="empty-state">Chưa có đồ uống nào</div>
                <div id="cartList"></div>
                <div id="cartTotalRow" class="cart-total" style="display:none">
                    <span>Tổng cộng:</span>
                    <span id="grandTotal">0đ</span>
                </div>
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

    // ---- Tìm kiếm client-side ----
    document.getElementById('drinkSearch').addEventListener('input', function() {
        var kw = this.value.toLowerCase().trim();
        var items = document.querySelectorAll('.drink-item');
        var found = 0;
        items.forEach(function(el) {
            var match = el.getAttribute('data-search').indexOf(kw) >= 0;
            el.classList.toggle('hidden', !match);
            if (match) found++;
        });
        document.getElementById('noResult').style.display = found === 0 ? 'block' : 'none';
    });

    // ---- Click chọn đồ uống ----
    document.querySelectorAll('.drink-item').forEach(function(el) {
        el.addEventListener('click', function() {
            var id    = parseInt(this.getAttribute('data-id'));
            var name  = this.getAttribute('data-name');
            var price = parseInt(this.getAttribute('data-price'));
            addDrink(id, name, price);
        });
    });

    function addDrink(id, name, price) {
        if (cart[id]) { cart[id].qty++; }
        else { cart[id] = { name: name, price: price, qty: 1 }; }
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
        var cartList     = document.getElementById('cartList');
        var hiddenInputs = document.getElementById('cartHiddenInputs');
        var emptyCart    = document.getElementById('emptyCart');
        var totalRow     = document.getElementById('cartTotalRow');
        var submitBtn    = document.getElementById('submitBtn');
        var grandTotal   = document.getElementById('grandTotal');

        cartList.innerHTML     = '';
        hiddenInputs.innerHTML = '';

        var total = 0, count = 0;

        Object.keys(cart).forEach(function(id) {
            var item = cart[id];
            var sub  = item.price * item.qty;
            total += sub; count++;

            var row = document.createElement('div');
            row.className = 'cart-item';

            var info = document.createElement('div');
            info.style.flex = '1'; info.style.minWidth = '0';
            var nm = document.createElement('div'); nm.className = 'cart-item-name'; nm.textContent = item.name;
            var pr = document.createElement('div'); pr.className = 'cart-item-price'; pr.textContent = nf.format(item.price) + 'đ';
            info.appendChild(nm); info.appendChild(pr);

            var qtyWrap = document.createElement('div'); qtyWrap.className = 'cart-item-qty';
            var btnM = document.createElement('button'); btnM.type = 'button'; btnM.textContent = '−';
            btnM.setAttribute('data-id', id);
            btnM.addEventListener('click', function(){ changeQty(parseInt(this.getAttribute('data-id')), -1); });
            var sp = document.createElement('span'); sp.textContent = item.qty;
            var btnP = document.createElement('button'); btnP.type = 'button'; btnP.textContent = '+';
            btnP.setAttribute('data-id', id);
            btnP.addEventListener('click', function(){ changeQty(parseInt(this.getAttribute('data-id')), 1); });
            qtyWrap.appendChild(btnM); qtyWrap.appendChild(sp); qtyWrap.appendChild(btnP);

            var subEl = document.createElement('div'); subEl.className = 'cart-item-sub'; subEl.textContent = nf.format(sub) + 'đ';

            var btnD = document.createElement('button'); btnD.type = 'button'; btnD.className = 'btn-remove'; btnD.textContent = '✕';
            btnD.setAttribute('data-id', id);
            btnD.addEventListener('click', function(){ removeItem(parseInt(this.getAttribute('data-id'))); });

            row.appendChild(info); row.appendChild(qtyWrap); row.appendChild(subEl); row.appendChild(btnD);
            cartList.appendChild(row);

            var i1 = document.createElement('input'); i1.type='hidden'; i1.name='drinkId[]'; i1.value=id;
            var i2 = document.createElement('input'); i2.type='hidden'; i2.name='quantity[]'; i2.value=item.qty;
            hiddenInputs.appendChild(i1); hiddenInputs.appendChild(i2);
        });

        grandTotal.textContent  = nf.format(total) + 'đ';
        emptyCart.style.display = count === 0 ? 'block' : 'none';
        totalRow.style.display  = count === 0 ? 'none'  : 'flex';
        submitBtn.disabled      = count === 0;
    }
</script>
</main></div>
</body>
</html>
