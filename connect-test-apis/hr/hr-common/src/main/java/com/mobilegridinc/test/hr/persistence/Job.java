/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.persistence;

import javax.persistence.*;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/** Jobs persistent container class
 *
 * Created by tony on 9/9/14.
 */
@XmlRootElement (name = "job")
@XmlAccessorType (XmlAccessType.FIELD)

@Entity
@Table (name = "Job", schema = "", catalog = "test_hr_schema")
public class Job {
    @XmlElement private int jobId;
    @XmlElement private String jobTitle;
    @XmlElement private Float minSalary;
    @XmlElement private Float maxSalary;

    @Id     // DB Auto Generates Value
    @Column (name = "JobID", nullable = false, insertable = true, updatable = true)
    public int getJobId () {
        return jobId;
    }

    public void setJobId (int jobId) {
        this.jobId = jobId;
    }

    @Basic
    @Column (name = "JobTitle", nullable = false, insertable = true, updatable = true, length = 35)
    public String getJobTitle () {
        return jobTitle;
    }

    public void setJobTitle (String jobTitle) {
        this.jobTitle = jobTitle;
    }

    @Basic
    @Column (name = "MinSalary", nullable = true, insertable = true, updatable = true, precision = 0)
    public Float getMinSalary () {
        return minSalary;
    }

    public void setMinSalary (Float minSalary) {
        this.minSalary = minSalary;
    }

    @Basic
    @Column (name = "MaxSalary", nullable = true, insertable = true, updatable = true, precision = 0)
    public Float getMaxSalary () {
        return maxSalary;
    }

    public void setMaxSalary (Float maxSalary) {
        this.maxSalary = maxSalary;
    }

    @Override
    public boolean equals (Object o) {
        if (this == o) return true;
        if (o == null || getClass () != o.getClass ()) return false;

        Job that = (Job) o;

        if (jobId != that.jobId) return false;
        if (jobTitle != null ? !jobTitle.equals (that.jobTitle) : that.jobTitle != null) return false;
        if (maxSalary != null ? !maxSalary.equals (that.maxSalary) : that.maxSalary != null) return false;
        if (minSalary != null ? !minSalary.equals (that.minSalary) : that.minSalary != null) return false;

        return true;
    }

    @Override
    public int hashCode () {
        int result = jobId;
        result = 31 * result + (jobTitle != null ? jobTitle.hashCode () : 0);
        result = 31 * result + (minSalary != null ? minSalary.hashCode () : 0);
        result = 31 * result + (maxSalary != null ? maxSalary.hashCode () : 0);
        return result;
    }
}
