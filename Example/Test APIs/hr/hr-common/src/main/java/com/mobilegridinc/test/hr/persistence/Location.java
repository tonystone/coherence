/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/** Locations persistent container class
 *
 * Created by tony on 9/9/14.
 */
@XmlRootElement (name = "location")
@XmlAccessorType (XmlAccessType.FIELD)

@Entity
@Table (name = "Location", schema = "", catalog = "test_hr_schema")
public class Location {
    @XmlElement private int locationId;
    @XmlElement private String streetAddress;
    @XmlElement private String postalCode;
    @XmlElement private String city;
    @XmlElement private String stateProvince;
    @XmlElement private String countryCode;

    @Id     // DB Auto Generates Value
    @Column (name = "LocationID", nullable = false, insertable = true, updatable = true)
    public int getLocationId () {
        return locationId;
    }

    public void setLocationId (int locationId) {
        this.locationId = locationId;
    }

    @Basic
    @Column (name = "StreetAddress", nullable = true, insertable = true, updatable = true, length = 40)
    public String getStreetAddress () {
        return streetAddress;
    }

    public void setStreetAddress (String streetAddress) {
        this.streetAddress = streetAddress;
    }

    @Basic
    @Column (name = "PostalCode", nullable = true, insertable = true, updatable = true, length = 12)
    public String getPostalCode () {
        return postalCode;
    }

    public void setPostalCode (String postalCode) {
        this.postalCode = postalCode;
    }

    @Basic
    @Column (name = "City", nullable = false, insertable = true, updatable = true, length = 30)
    public String getCity () {
        return city;
    }

    public void setCity (String city) {
        this.city = city;
    }

    @Basic
    @Column (name = "StateProvince", nullable = true, insertable = true, updatable = true, length = 25)
    public String getStateProvince () {
        return stateProvince;
    }

    public void setStateProvince (String stateProvince) {
        this.stateProvince = stateProvince;
    }

    @Basic
    @Column (name = "CountryCode", nullable = false, insertable = true, updatable = true, length = 2)
    public String getCountryCode () {
        return countryCode;
    }

    public void setCountryCode (String countryCode) {
        this.countryCode = countryCode;
    }


    @Override
    public boolean equals (Object o) {
        if (this == o) return true;
        if (o == null || getClass () != o.getClass ()) return false;

        Location that = (Location) o;

        if (locationId != that.locationId) return false;
        if (city != null ? !city.equals (that.city) : that.city != null) return false;
        if (postalCode != null ? !postalCode.equals (that.postalCode) : that.postalCode != null) return false;
        if (stateProvince != null ? !stateProvince.equals (that.stateProvince) : that.stateProvince != null)
            return false;
        if (streetAddress != null ? !streetAddress.equals (that.streetAddress) : that.streetAddress != null)
            return false;

        return true;
    }

    @Override
    public int hashCode () {
        int result = locationId;
        result = 31 * result + (streetAddress != null ? streetAddress.hashCode () : 0);
        result = 31 * result + (postalCode != null ? postalCode.hashCode () : 0);
        result = 31 * result + (city != null ? city.hashCode () : 0);
        result = 31 * result + (stateProvince != null ? stateProvince.hashCode () : 0);
        return result;
    }

}
