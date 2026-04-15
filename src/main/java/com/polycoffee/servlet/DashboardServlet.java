package com.polycoffee.servlet;

import com.polycoffee.dao.BillDAO;
import com.polycoffee.dao.DrinkDAO;
import com.polycoffee.dao.UserDAO;
import com.polycoffee.util.ParamUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet({"/admin/dashboard", "/admin/reports"})
public class DashboardServlet extends HttpServlet {

    private final BillDAO  billDAO  = new BillDAO();
    private final DrinkDAO drinkDAO = new DrinkDAO();
    private final UserDAO  userDAO  = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String uri = req.getRequestURI();

        if (uri.endsWith("/dashboard")) {
            showDashboard(req, resp);
        } else {
            showReports(req, resp);
        }
    }

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Thống kê nhanh: doanh thu hôm nay và tháng này
        Calendar cal = Calendar.getInstance();
        Date today = cal.getTime();
        cal.set(Calendar.DAY_OF_MONTH, 1);
        Date firstOfMonth = cal.getTime();

        List<Map<String, Object>> todayRevenue  = billDAO.revenueByDay(today, today);
        List<Map<String, Object>> monthRevenue  = billDAO.revenueByDay(firstOfMonth, today);

        double todayTotal = todayRevenue.stream().mapToDouble(r -> (Double) r.get("revenue")).sum();
        double monthTotal = monthRevenue.stream().mapToDouble(r -> (Double) r.get("revenue")).sum();

        req.setAttribute("todayRevenue", todayTotal);
        req.setAttribute("monthRevenue", monthTotal);
        req.setAttribute("topDrinks",    billDAO.topDrinks(5));
        req.setAttribute("totalDrinks",  drinkDAO.findAll().size());
        req.setAttribute("totalStaff",   userDAO.findAllStaff().size());

        req.getRequestDispatcher("/views/admin/dashboard.jsp").forward(req, resp);
    }

    private void showReports(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String fromStr = ParamUtil.getString(req, "from");
        String toStr   = ParamUtil.getString(req, "to");
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        Date from, to;
        try {
            from = fromStr.isEmpty() ? getFirstDayOfMonth() : sdf.parse(fromStr);
            to   = toStr.isEmpty()   ? new Date()           : sdf.parse(toStr);
        } catch (Exception e) {
            from = getFirstDayOfMonth();
            to   = new Date();
        }

        req.setAttribute("revenueByDay", billDAO.revenueByDay(from, to));
        req.setAttribute("topDrinks",    billDAO.topDrinks(10));
        req.setAttribute("from",         sdf.format(from));
        req.setAttribute("to",           sdf.format(to));

        req.getRequestDispatcher("/views/admin/reports.jsp").forward(req, resp);
    }

    private Date getFirstDayOfMonth() {
        Calendar c = Calendar.getInstance();
        c.set(Calendar.DAY_OF_MONTH, 1);
        c.set(Calendar.HOUR_OF_DAY, 0);
        c.set(Calendar.MINUTE, 0);
        c.set(Calendar.SECOND, 0);
        return c.getTime();
    }
}
