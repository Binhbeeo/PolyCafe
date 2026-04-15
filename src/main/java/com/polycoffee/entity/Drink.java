package com.polycoffee.entity;

import java.io.Serializable;

/**
 * Entity: Drink - Đồ uống
 */
public class Drink implements Serializable {
    private int id;
    private int categoryId;
    private String name;
    private double price;
    private String image;
    private String description;
    private boolean active;

    // For join queries
    private String categoryName;

    public Drink() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }
}
