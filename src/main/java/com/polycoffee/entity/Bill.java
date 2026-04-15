package com.polycoffee.entity;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

/**
 * Entity: Bill - Hóa đơn
 */
public class Bill implements Serializable {
    private int id;
    private int userId;
    private String code;
    private Date createdAt;
    private double total;
    private String status;  // waiting | finish | cancel

    // Join fields
    private String userFullName;
    private List<BillDetail> details;

    public Bill() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public double getTotal() { return total; }
    public void setTotal(double total) { this.total = total; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getUserFullName() { return userFullName; }
    public void setUserFullName(String userFullName) { this.userFullName = userFullName; }

    public List<BillDetail> getDetails() { return details; }
    public void setDetails(List<BillDetail> details) { this.details = details; }

    public boolean isWaiting()  { return "waiting".equalsIgnoreCase(status); }
    public boolean isFinished() { return "finish".equalsIgnoreCase(status); }
    public boolean isCancelled(){ return "cancel".equalsIgnoreCase(status); }
}
