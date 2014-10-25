/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Employee;
import com.mobilegridinc.test.hr.persistence.PersistenceManager;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;
import java.util.HashMap;
import java.util.List;

/** Employees REST Controller
 *
 * Created by tony on 9/9/14.
 */
public class EmployeesResourceController implements EmployeesResource {

    private PersistenceManager<Employee> persistenceManager = null;
    private UriInfo uriInfo                                = null;

    public EmployeesResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Employee.class);
    }

    @Override
    public List<Employee> listEmployees () {
        return persistenceManager.list ();
    }

    @Override
    public Response insertEmployee (Employee employee) {

        Response response = null;

        Employee newEmployee = persistenceManager.insert (employee);

        if (newEmployee != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.path ("{employeeId}").build (newEmployee.getEmployeeId ());

            response = Response.created (locationUri).entity (newEmployee).build ();
        }
        return response;
    }

    @Override
    public Employee readEmployee (int employeeId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("employeeId", employeeId);

        Employee employee = persistenceManager.read (criteria);

        if (employee == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return employee;
    }

    @Override
    public Response updateEmployee (@SuppressWarnings ("unused") int employeeId, Employee employee) {

        Employee updatedEmployee = persistenceManager.update (employee);

        if (updatedEmployee == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteEmployee (int employeeId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("employeeId", employeeId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

}
