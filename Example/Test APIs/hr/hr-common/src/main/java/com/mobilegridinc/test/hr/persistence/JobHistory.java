/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.sql.Date;

/** JobHistory persistent container class
 *
 * Created by tony on 9/9/14.
 */
@XmlRootElement (name = "department")
@XmlAccessorType (XmlAccessType.FIELD)

@Entity
@Table (name = "JobHistory", schema = "", catalog = "test_hr_schema")
@IdClass (JobHistoryPK.class)
public class JobHistory {
    @XmlElement private int employeeId;
    @XmlElement private Date startDate;
    @XmlElement private Date endDate;
    private Department departmentsByDepartmentId;

    @Id     // DB Auto Generates Value
    @Column (name = "EmployeeID", nullable = false, insertable = true, updatable = true)
    public int getEmployeeId () {
        return employeeId;
    }

    public void setEmployeeId (int employeeId) {
        this.employeeId = employeeId;
    }

    @Id
    @Column (name = "StartDate", nullable = false, insertable = true, updatable = true)
    public Date getStartDate () {
        return startDate;
    }

    public void setStartDate (Date startDate) {
        this.startDate = startDate;
    }

    @Basic
    @Column (name = "EndDate", nullable = false, insertable = true, updatable = true)
    public Date getEndDate () {
        return endDate;
    }

    public void setEndDate (Date endDate) {
        this.endDate = endDate;
    }

    @Override
    public boolean equals (Object o) {
        if (this == o) return true;
        if (o == null || getClass () != o.getClass ()) return false;

        JobHistory that = (JobHistory) o;

        if (employeeId != that.employeeId) return false;
        if (endDate != null ? !endDate.equals (that.endDate) : that.endDate != null) return false;
        if (startDate != null ? !startDate.equals (that.startDate) : that.startDate != null) return false;

        return true;
    }

    @Override
    public int hashCode () {
        int result = employeeId;
        result = 31 * result + (startDate != null ? startDate.hashCode () : 0);
        result = 31 * result + (endDate != null ? endDate.hashCode () : 0);
        return result;
    }

    @ManyToOne
    @JoinColumn (name = "DepartmentID", referencedColumnName = "DepartmentID", nullable = false)
    public Department getDepartmentsByDepartmentId () {
        return departmentsByDepartmentId;
    }

    public void setDepartmentsByDepartmentId (Department departmentsByDepartmentId) {
        this.departmentsByDepartmentId = departmentsByDepartmentId;
    }
}
