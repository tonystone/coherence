/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.math.BigDecimal;
import java.sql.Date;

/** Employees persistent container class
 *
 * Created by tony on 9/9/14.
 */
@XmlRootElement (name = "employee")
@XmlAccessorType (XmlAccessType.FIELD)

@Entity
@Table (name = "Employee", schema = "", catalog = "test_hr_schema")
public class Employee {
    @XmlElement private int employeeId;
    @XmlElement private int departmentId;
    @XmlElement private String firstName;
    @XmlElement private String lastName;
    @XmlElement private String email;
    @XmlElement private String phoneNumber;
    @XmlElement private Date hireDate;
    @XmlElement private BigDecimal salary;
    @XmlElement private BigDecimal commissionPercentage;

    @Id     // DB Auto Generates Value
    @Column (name = "EmployeeID", nullable = false, insertable = true, updatable = true)
    public int getEmployeeId () {
        return employeeId;
    }

    public void setEmployeeId (int employeeId) {
        this.employeeId = employeeId;
    }

    @Basic
    @Column (name = "DepartmentID", nullable = true, insertable = true, updatable = true)
    public int getDepartmentId () {
        return departmentId;
    }

    public void setDepartmentId (int departmentId) {
        this.departmentId = departmentId;
    }

    @Basic
    @Column (name = "FirstName", nullable = true, insertable = true, updatable = true, length = 20)
    public String getFirstName () {
        return firstName;
    }

    public void setFirstName (String firstName) {
        this.firstName = firstName;
    }

    @Basic
    @Column (name = "LastName", nullable = false, insertable = true, updatable = true, length = 25)
    public String getLastName () {
        return lastName;
    }

    public void setLastName (String lastName) {
        this.lastName = lastName;
    }

    @Basic
    @Column (name = "Email", nullable = false, insertable = true, updatable = true, length = 50)
    public String getEmail () {
        return email;
    }

    public void setEmail (String email) {
        this.email = email;
    }

    @Basic
    @Column (name = "PhoneNumber", nullable = true, insertable = true, updatable = true, length = 20)
    public String getPhoneNumber () {
        return phoneNumber;
    }

    public void setPhoneNumber (String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    @Basic
    @Column (name = "HireDate", nullable = false, insertable = true, updatable = true)
    public Date getHireDate () {
        return hireDate;
    }

    public void setHireDate (Date hireDate) {
        this.hireDate = hireDate;
    }

    @Basic
    @Column (name = "Salary", nullable = true, insertable = true, updatable = true, precision = 2)
    public BigDecimal getSalary () {
        return salary;
    }

    public void setSalary (BigDecimal salary) {
        this.salary = salary;
    }

    @Basic
    @Column (name = "CommissionPercentage", nullable = true, insertable = true, updatable = true, precision = 2)
    public BigDecimal getCommissionPercentage () {
        return commissionPercentage;
    }

    public void setCommissionPercentage (BigDecimal commissionPercentage) {
        this.commissionPercentage = commissionPercentage;
    }

    @Override
    public boolean equals (Object o) {
        if (this == o) return true;
        if (o == null || getClass () != o.getClass ()) return false;

        Employee that = (Employee) o;

        if (employeeId != that.employeeId) return false;
        if (commissionPercentage != null ? !commissionPercentage.equals (that.commissionPercentage) : that.commissionPercentage != null)
            return false;
        if (email != null ? !email.equals (that.email) : that.email != null) return false;
        if (firstName != null ? !firstName.equals (that.firstName) : that.firstName != null) return false;
        if (hireDate != null ? !hireDate.equals (that.hireDate) : that.hireDate != null) return false;
        if (lastName != null ? !lastName.equals (that.lastName) : that.lastName != null) return false;
        if (phoneNumber != null ? !phoneNumber.equals (that.phoneNumber) : that.phoneNumber != null) return false;
        if (salary != null ? !salary.equals (that.salary) : that.salary != null) return false;

        return true;
    }

    @Override
    public int hashCode () {
        int result = employeeId;
        result = 31 * result + (firstName != null ? firstName.hashCode () : 0);
        result = 31 * result + (lastName != null ? lastName.hashCode () : 0);
        result = 31 * result + (email != null ? email.hashCode () : 0);
        result = 31 * result + (phoneNumber != null ? phoneNumber.hashCode () : 0);
        result = 31 * result + (hireDate != null ? hireDate.hashCode () : 0);
        result = 31 * result + (salary != null ? salary.hashCode () : 0);
        result = 31 * result + (commissionPercentage != null ? commissionPercentage.hashCode () : 0);
        return result;
    }

}
