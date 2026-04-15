package com.polycoffee.entity;

import java.io.Serializable;

/**
 * Entity: User - Tài khoản người dùng (admin / staff)
 */
public class User implements Serializable {
    private int id;
    private String email;
    private String password;
    private String fullName;
    private String phone;
    private String role;   // "admin" | "staff"
    private boolean active;

    public User() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public boolean isAdmin() { return "admin".equalsIgnoreCase(role); }
}
