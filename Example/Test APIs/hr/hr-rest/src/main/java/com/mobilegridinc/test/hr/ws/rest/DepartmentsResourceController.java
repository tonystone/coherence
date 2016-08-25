/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Department;
import com.mobilegridinc.test.hr.persistence.PersistenceManager;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;
import java.util.HashMap;
import java.util.List;

/** Departments REST Controller
 *
 * Created by tony on 9/9/14.
 */
public class DepartmentsResourceController implements DepartmentsResource {

    private PersistenceManager<Department> persistenceManager = null;
    private UriInfo uriInfo                                = null;

    public DepartmentsResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Department.class);
    }

    @Override
    public List<Department> listDepartments () {
        return persistenceManager.list ();
    }

    @Override
    public Response insertDepartment (Department department) {

        Response response = null;

        Department newDepartment = persistenceManager.insert (department);

        if (newDepartment != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.path ("{departmentId}").build (newDepartment.getDepartmentId ());

            response = Response.created (locationUri).entity (newDepartment).build ();
        }
        return response;
    }

    @Override
    public Department readDepartment (int departmentId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("departmentId", departmentId);

        Department department = persistenceManager.read (criteria);

        if (department == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return department;
    }

    @Override
    public Response updateDepartment (@SuppressWarnings ("unused") int departmentId, Department department) {

        Department updatedDepartment = persistenceManager.update (department);

        if (updatedDepartment == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteDepartment (int departmentId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("departmentId", departmentId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

}
