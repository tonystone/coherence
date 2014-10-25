/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.JobHistory;
import com.mobilegridinc.test.hr.persistence.PersistenceManager;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;
import java.util.Date;
import java.util.HashMap;
import java.util.List;


/** Countries REST Controller
 *
 * Created by tony on 9/9/14.
 */
public class EmployeesEmployeeIdJobHistoryResourceController implements EmployeesEmployeeIdJobHistoryResource {

    private PersistenceManager<JobHistory> persistenceManager = null;
    private UriInfo uriInfo                                   = null;

    public EmployeesEmployeeIdJobHistoryResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (JobHistory.class);
    }

    @Override
    public List<JobHistory> listEmployeeJobHistory(int employeeId) {
        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("employeeId", employeeId);

        return persistenceManager.list (criteria);
    }

    @Override
    public Response insertEmployeeJobHistory (int employeeId, JobHistory jobHistory)  {

        if (employeeId != jobHistory.getEmployeeId ()) {
            throw new WebApplicationException (400);    // Bad Request
        }

        Response response = null;

        JobHistory newJobHistory = persistenceManager.insert (jobHistory);

        if (newJobHistory != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.path ("{startDate}").build (newJobHistory.getStartDate ());

            response = Response.created (locationUri).entity (newJobHistory).build ();
        }
        return response;
    }

    @Override
    public JobHistory readEmployeeJobHistory(int employeeId, Date startDate) {

        HashMap<String, Object> criteria = new HashMap<> (2);

        criteria.put ("employeeId", employeeId);
        criteria.put ("startDate" , startDate);

        JobHistory jobHistory = persistenceManager.read (criteria);

        if (jobHistory == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return jobHistory;
    }

    @Override
    public Response updateEmployeeJobHistory (int employeeId, Date startDate, JobHistory jobHistory) {

        if (employeeId != jobHistory.getEmployeeId () || startDate != jobHistory.getStartDate ()) {
            throw new WebApplicationException (400);    // Bad Request
        }

        JobHistory updatedJobHistory = persistenceManager.update (jobHistory);

        if (updatedJobHistory == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteEmployeeJobHistory(int employeeId, Date startDate)  {

        HashMap<String, Object> criteria = new HashMap<> (2);

        criteria.put ("employeeId", employeeId);
        criteria.put ("startDate" , startDate);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }
}
