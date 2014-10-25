/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.Column;
import javax.persistence.Id;
import java.io.Serializable;

/**
 * Created by tony on 10/1/14.
 */
public class LocationDepartmentPK implements Serializable {
    private int locationId;
    private int departmentId;

    @Column (name = "LocationId", nullable = false, insertable = true, updatable = true)
    @Id
    public int getLocationId () {
        return locationId;
    }

    public void setLocationId (int locationId) {
        this.locationId = locationId;
    }

    @Column (name = "DepartmentId", nullable = false, insertable = true, updatable = true)
    @Id
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

        LocationDepartmentPK that = (LocationDepartmentPK) o;

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
