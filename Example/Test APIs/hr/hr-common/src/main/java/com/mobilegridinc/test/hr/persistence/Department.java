/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
/** Departments persistent container class
 *
 * Created by tony on 9/9/14.
 */
@XmlRootElement (name = "department")
@XmlAccessorType (XmlAccessType.FIELD)

@Entity
@Table (name = "Department", schema = "", catalog = "test_hr_schema")
public class Department {
    @XmlElement private int departmentId;
    @XmlElement private String departmentName;

    @Id     // DB Auto Generates Value
    @Column (name = "DepartmentID", nullable = false, insertable = true, updatable = true)
    public int getDepartmentId () {
        return departmentId;
    }

    public void setDepartmentId (int departmentId) {
        this.departmentId = departmentId;
    }

    @Basic
    @Column (name = "DepartmentName", nullable = false, insertable = true, updatable = true, length = 30)
    public String getDepartmentName () {
        return departmentName;
    }

    public void setDepartmentName (String departmentName) {
        this.departmentName = departmentName;
    }

    @Override
    public boolean equals (Object o) {
        if (this == o) return true;
        if (o == null || getClass () != o.getClass ()) return false;

        Department that = (Department) o;

        if (departmentId != that.departmentId) return false;
        if (departmentName != null ? !departmentName.equals (that.departmentName) : that.departmentName != null)
            return false;

        return true;
    }

    @Override
    public int hashCode () {
        int result = departmentId;
        result = 31 * result + (departmentName != null ? departmentName.hashCode () : 0);
        return result;
    }
}
