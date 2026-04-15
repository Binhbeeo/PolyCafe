package com.polycoffee.entity;

import java.io.Serializable;

/**
 * Entity: BillDetail - Chi tiết hóa đơn
 */
public class BillDetail implements Serializable {
    private int id;
    private int billId;
    private int drinkId;
    private int quantity;
    private double price;

    // Join fields
    private String drinkName;
    private String drinkImage;

    public BillDetail() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBillId() { return billId; }
    public void setBillId(int billId) { this.billId = billId; }

    public int getDrinkId() { return drinkId; }
    public void setDrinkId(int drinkId) { this.drinkId = drinkId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getDrinkName() { return drinkName; }
    public void setDrinkName(String drinkName) { this.drinkName = drinkName; }

    public String getDrinkImage() { return drinkImage; }
    public void setDrinkImage(String drinkImage) { this.drinkImage = drinkImage; }

    public double getSubTotal() { return quantity * price; }
}
