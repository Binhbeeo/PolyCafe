package com.polycoffee.servlet;

import com.polycoffee.dao.BillDAO;
import com.polycoffee.dao.DrinkDAO;
import com.polycoffee.entity.Bill;
import com.polycoffee.entity.Drink;
import com.polycoffee.entity.User;
import com.polycoffee.util.AuthUtil;
import com.polycoffee.util.ParamUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet({"/admin/bills", "/staff/bills"})
public class BillServlet extends HttpServlet {

    private final BillDAO  billDAO  = new BillDAO();
    private final DrinkDAO drinkDAO = new DrinkDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uri    = req.getRequestURI();
        String action = ParamUtil.getString(req, "action");
        int id        = ParamUtil.getInt(req, "id");
        User  current = AuthUtil.getUser(req);
        boolean isAdmin = AuthUtil.isManager(req);

        switch (action) {

            // Chi tiết hóa đơn
            case "detail":
                Bill bill = billDAO.findById(id);
                if (bill == null) { resp.sendRedirect(req.getContextPath() + (isAdmin ? "/admin/bills" : "/staff/bills")); return; }
                // Kiểm tra quyền: staff chỉ xem được hóa đơn của chính mình
                if (!isAdmin && bill.getUserId() != current.getId()) {
                    resp.sendRedirect(req.getContextPath() + "/staff/bills");
                    return;
                }
                req.setAttribute("bill", bill);
                req.getRequestDispatcher("/views/" + (isAdmin ? "admin" : "staff") + "/bill-detail.jsp").forward(req, resp);
                break;

            // Form tạo hóa đơn mới (staff)
            case "new":
                req.setAttribute("drinks", drinkDAO.findAllActive());
                req.getRequestDispatcher("/views/staff/bill-new.jsp").forward(req, resp);
                break;

            // Chuyển trạng thái
            case "finish":
                if (billDAO.updateStatus(id, "finish", isAdmin)) {
                    resp.sendRedirect(req.getContextPath() + (isAdmin ? "/admin/bills" : "/staff/bills") + "?msg=finished");
                } else {
                    resp.sendRedirect(req.getContextPath() + (isAdmin ? "/admin/bills" : "/staff/bills") + "?msg=err_status");
                }
                break;
            case "cancel":
                if (billDAO.updateStatus(id, "cancel", isAdmin)) {
                    resp.sendRedirect(req.getContextPath() + (isAdmin ? "/admin/bills" : "/staff/bills") + "?msg=cancelled");
                } else {
                    resp.sendRedirect(req.getContextPath() + (isAdmin ? "/admin/bills" : "/staff/bills") + "?msg=err_status");
                }
                break;

            // Danh sách hóa đơn
            default:
                List<Bill> bills;
                if (isAdmin) {
                    String status = ParamUtil.getString(req, "status");
                    bills = status.isEmpty() ? billDAO.findAll() : billDAO.findByStatus(status);
                    req.setAttribute("filterStatus", status);
                } else {
                    bills = billDAO.findByUser(current.getId());
                }
                req.setAttribute("bills", bills);
                req.getRequestDispatcher("/views/" + (isAdmin ? "admin" : "staff") + "/bill-list.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = ParamUtil.getString(req, "action");
        User current  = AuthUtil.getUser(req);

        // Tạo hóa đơn mới
        if ("create".equals(action)) {
            String[] drinkIds   = req.getParameterValues("drinkId[]");
            String[] quantities = req.getParameterValues("quantity[]");

            if (drinkIds == null || drinkIds.length == 0) {
                req.setAttribute("error", "Vui lòng chọn ít nhất một đồ uống.");
                req.setAttribute("drinks", drinkDAO.findAllActive());
                req.getRequestDispatcher("/views/staff/bill-new.jsp").forward(req, resp);
                return;
            }

            Map<Integer, Integer> items  = new LinkedHashMap<>();
            Map<Integer, Double>  prices = new LinkedHashMap<>();

            for (int i = 0; i < drinkIds.length; i++) {
                if (drinkIds[i] == null || drinkIds[i].trim().isEmpty()) continue;
                int drinkId;
                try { drinkId = Integer.parseInt(drinkIds[i].trim()); } catch (NumberFormatException e) { continue; }
                int qty = 1;
                if (quantities != null && i < quantities.length
                        && quantities[i] != null && !quantities[i].trim().isEmpty()) {
                    try { qty = Integer.parseInt(quantities[i].trim()); } catch (NumberFormatException e) { qty = 1; }
                }
                if (qty > 0) {
                    items.put(drinkId, qty);
                    Drink drink = drinkDAO.findById(drinkId);
                    if (drink != null) prices.put(drinkId, drink.getPrice());
                }
            }

            int billId = billDAO.createBillWithDetails(current.getId(), items, prices);
            if (billId > 0) {
                resp.sendRedirect(req.getContextPath() + "/staff/bills?action=detail&id=" + billId + "&msg=created");
            } else {
                req.setAttribute("error", "Tạo hóa đơn thất bại. Vui lòng thử lại.");
                req.setAttribute("drinks", drinkDAO.findAllActive());
                req.getRequestDispatcher("/views/staff/bill-new.jsp").forward(req, resp);
            }
            return;
        }

        // Cập nhật số lượng trong hóa đơn
        if ("updateQty".equals(action)) {
            int billId  = ParamUtil.getInt(req, "billId");
            int drinkId = ParamUtil.getInt(req, "drinkId");
            int qty     = ParamUtil.getInt(req, "quantity");
            billDAO.updateDetailQuantity(billId, drinkId, qty);
            boolean isAdmin = AuthUtil.isManager(req);
            resp.sendRedirect(req.getContextPath() + (isAdmin ? "/admin/bills" : "/staff/bills") + "?action=detail&id=" + billId);
        }
    }
}
