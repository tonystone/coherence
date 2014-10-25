/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/** Countries persistent container class
 *
 * Created by tony on 9/9/14.
 */
@XmlRootElement (name = "country")
@XmlAccessorType (XmlAccessType.FIELD)

@Entity
@Table (name = "Country", schema = "", catalog = "test_hr_schema")
public class Country {
    @XmlElement private String countryCode;
    @XmlElement private String countryName;
    @XmlElement private int    regionId;

    @Id
    @Column (name = "CountryCode", nullable = false, insertable = true, updatable = true, length = 2)
    public String getCountryCode () {
        return countryCode;
    }

    public void setCountryCode (String countryCode) {
        this.countryCode = countryCode;
    }

    @Basic
    @Column (name = "CountryName", nullable = true, insertable = true, updatable = true, length = 40)
    public String getCountryName () {
        return countryName;
    }

    public void setCountryName (String countryName) {
        this.countryName = countryName;
    }

    @Basic
    @Column (name = "RegionID", nullable = true, insertable = true, updatable = true)
    public int getRegionId () {
        return regionId;
    }

    public void setRegionId (int regionId) {
        this.regionId = regionId;
    }

    @Override
    public boolean equals (Object o) {
        if (this == o) return true;
        if (o == null || getClass () != o.getClass ()) return false;

        Country that = (Country) o;

        if (countryCode != null ? !countryCode.equals (that.countryCode) : that.countryCode != null) return false;
        if (countryName != null ? !countryName.equals (that.countryName) : that.countryName != null) return false;

        return true;
    }

    @Override
    public int hashCode () {
        int result = countryCode != null ? countryCode.hashCode () : 0;
        result = 31 * result + (countryName != null ? countryName.hashCode () : 0);
        return result;
    }
}
