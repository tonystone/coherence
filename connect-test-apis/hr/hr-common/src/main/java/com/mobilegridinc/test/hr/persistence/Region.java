/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/** Regions persistent container class
 *
 * Created by tony on 9/9/14.
 */
@XmlRootElement(name = "region")
@XmlAccessorType(XmlAccessType.FIELD)

@Entity
@Table (name = "Region", schema = "", catalog = "test_hr_schema")
public class Region {
    @XmlElement private int regionId;
    @XmlElement private String regionName;

    // JAXB really requires a no-argument constructor...
    public Region () {}

    @Id     // DB Auto Generates Value
    @Column (name = "RegionID", nullable = false, insertable = true, updatable = true)
    public int getRegionId () {
        return regionId;
    }

    public void setRegionId (int regionId) {
        this.regionId = regionId;
    }

    @Basic
    @Column (name = "RegionName", nullable = true, insertable = true, updatable = true, length = 25)

    public String getRegionName () {
        return regionName;
    }

    public void setRegionName (String regionName) {
        this.regionName = regionName;
    }

    @Override
    public boolean equals (Object o) {
        if (this == o) return true;
        if (o == null || getClass () != o.getClass ()) return false;

        Region that = (Region) o;

        if (regionId != that.regionId) return false;
        if (regionName != null ? !regionName.equals (that.regionName) : that.regionName != null) return false;

        return true;
    }

    @Override
    public int hashCode () {
        int result = regionId;
        result = 31 * result + (regionName != null ? regionName.hashCode () : 0);
        return result;
    }
}
