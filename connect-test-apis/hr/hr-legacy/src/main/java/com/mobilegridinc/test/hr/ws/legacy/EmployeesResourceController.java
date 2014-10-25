/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

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

public class EmployeesResourceController implements EmployeesResource {

    private PersistenceManager<Employee> persistenceManager = null;
    private UriInfo uriInfo                                  = null;

    public EmployeesResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Employee.class);
    }

    @Override
    public List<Employee> getEmployees (Integer employeeId, Integer locationId, Integer departmentId) {

        HashMap<String, Object> criteria = new HashMap<> (3);

        if (employeeId != null)
            criteria.put ("employeeId", employeeId);

        if (locationId != null)
            criteria.put ("locationId", locationId);

        if (departmentId != null)
            criteria.put ("departmentId", departmentId);

        return persistenceManager.list (criteria);
    }

    @Override
    public Response postEmployee (Employee employee) {

        Response response = null;

        Employee newCountry = persistenceManager.insert (employee);

        if (newCountry != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.queryParam ("employeeId", newCountry.getEmployeeId ()).build ();

            response = Response.created (locationUri).entity (newCountry).build ();
        }
        return response;
    }

    @Override
    public Response putEmployee (Integer employeeId, Employee employee) {

        Employee updatedCountry = persistenceManager.update (employee);

        if (updatedCountry == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteEmployee (Integer employeeId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        if (employeeId != null)
            criteria.put ("employeeId", employeeId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }
    

}