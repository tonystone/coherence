/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.Column;
import javax.persistence.Id;
import java.io.Serializable;
import java.sql.Date;

/** JobHistoryPK persistent PK class
 *
 * Created by tony on 9/9/14.
 */
public class JobHistoryPK implements Serializable {
    private int employeeId;
    private Date startDate;

    @Column (name = "EmployeeID", nullable = false, insertable = true, updatable = true)
    @Id
    public int getEmployeeId () {
        return employeeId;
    }

    public void setEmployeeId (int employeeId) {
        this.employeeId = employeeId;
    }

    @Column (name = "StartDate", nullable = false, insertable = true, updatable = true)
    @Id
    public Date getStartDate () {
        return startDate;
    }

    public void setStartDate (Date startDate) {
        this.startDate = startDate;
    }

    @Override
    public boolean equals (Object o) {
        if (this == o) return true;
        if (o == null || getClass () != o.getClass ()) return false;

        JobHistoryPK that = (JobHistoryPK) o;

        if (employeeId != that.employeeId) return false;
        if (startDate != null ? !startDate.equals (that.startDate) : that.startDate != null) return false;

        return true;
    }

    @Override
    public int hashCode () {
        int result = employeeId;
        result = 31 * result + (startDate != null ? startDate.hashCode () : 0);
        return result;
    }
}
