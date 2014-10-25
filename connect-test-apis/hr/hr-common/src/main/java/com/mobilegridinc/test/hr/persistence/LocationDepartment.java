/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;

/**
 * Created by tony on 10/1/14.
 */
@Entity
@IdClass (LocationDepartmentPK.class)
public class LocationDepartment {
    private int locationId;
    private int departmentId;

    @Id
    @Column (name = "LocationId", nullable = false, insertable = true, updatable = true)
    public int getLocationId () {
        return locationId;
    }

    public void setLocationId (int locationId) {
        this.locationId = locationId;
    }

    @Id
    @Column (name = "DepartmentId", nullable = false, insertable = true, updatable = true)
    public int getDepartmentId () {
        return departmentId;
    }

    public void setDepartmentId (int departmentId) {
        this.departmentId = departmentId;
    }

    @Override
    public boolean equals (Object o) {
        if (this == o) return true;
        if (o == null || getClass () != o.getClass ()) return false;

        LocationDepartment that = (LocationDepartment) o;

        if (departmentId != that.departmentId) return false;
        if (locationId != that.locationId) return false;

        return true;
    }

    @Override
    public int hashCode () {
        int result = locationId;
        result = 31 * result + departmentId;
        return result;
    }
}
