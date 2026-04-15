package com.polycoffee.servlet;

import com.polycoffee.dao.CategoryDAO;
import com.polycoffee.dao.DrinkDAO;
import com.polycoffee.util.ParamUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet({"/", "/home"})
public class HomeServlet extends HttpServlet {

    private final DrinkDAO    drinkDAO    = new DrinkDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int categoryId = ParamUtil.getInt(req, "category");

        req.setAttribute("categories", categoryDAO.findAllActive());
        req.setAttribute("selectedCategory", categoryId);

        if (categoryId > 0) {
            req.setAttribute("drinks", drinkDAO.findByCategory(categoryId));
        } else {
            req.setAttribute("drinks", drinkDAO.findAllActive());
        }

        req.getRequestDispatcher("/views/customer/home.jsp").forward(req, resp);
    }
}
