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


/** Countries REST Controller
 *
 * Created by tony on 9/9/14.
 */
public class DepartmentsDepartmentIdEmployeesResourceController implements DepartmentsDepartmentIdEmployeesResource {

    private PersistenceManager<Employee> persistenceManager = null;
    private UriInfo uriInfo                                = null;

    public DepartmentsDepartmentIdEmployeesResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Employee.class);
    }

    @Override
    public List<Employee> listDepartmentEmployees (int departmentId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("departmentId", departmentId);
        
        return persistenceManager.list (criteria);
    }

    @Override
    public Response insertDepartmentEmployee (int departmentId, Employee employee) {

        if (departmentId != employee.getDepartmentId ()) {
            throw new WebApplicationException (400);    // Bad Request
        }

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
    public Employee readDepartmentEmployee (int departmentId, int employeeId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("employeeId", employeeId);

        Employee employee = persistenceManager.read (criteria);

        if (departmentId != employee.getDepartmentId ()) {
            throw new WebApplicationException (400);    // Bad Request
        }

        if (employee == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return employee;
    }

    @Override
    public Response updateDepartmentEmployee (int departmentId, @SuppressWarnings ("unused") int employeeId, Employee employee) {

        if (departmentId != employee.getDepartmentId ()) {
            throw new WebApplicationException (400);    // Bad Request
        }

        Employee updatedDepartmentEmployee = persistenceManager.update (employee);

        if (updatedDepartmentEmployee == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteDepartmentEmployee (int departmentId, int employeeId) {

        HashMap<String, Object> criteria = new HashMap<> (2);

        criteria.put ("departmentId", departmentId);
        criteria.put ("employeeId"  , employeeId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

}
