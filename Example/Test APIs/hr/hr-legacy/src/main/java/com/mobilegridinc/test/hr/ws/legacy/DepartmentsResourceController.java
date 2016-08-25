/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

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

public class DepartmentsResourceController implements DepartmentsResource {

    private PersistenceManager<Department> persistenceManager = null;
    private UriInfo uriInfo                                  = null;

    public DepartmentsResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Department.class);
    }

    @Override
    public List<Department> getDepartments (Integer departmentId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        if (departmentId != null)
            criteria.put ("departmentId", departmentId);

        return persistenceManager.list (criteria);
    }

    @Override
    public Response postDepartment (Department department) {

        Response response = null;

        Department newCountry = persistenceManager.insert (department);

        if (newCountry != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.queryParam ("departmentId", newCountry.getDepartmentId ()).build ();

            response = Response.created (locationUri).entity (newCountry).build ();
        }
        return response;
    }

    @Override
    public Response putDepartment (Integer departmentId, Department department) {

        Department updatedCountry = persistenceManager.update (department);

        if (updatedCountry == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteDepartment (Integer departmentId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        if (departmentId != null)
            criteria.put ("departmentId", departmentId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }
    
}