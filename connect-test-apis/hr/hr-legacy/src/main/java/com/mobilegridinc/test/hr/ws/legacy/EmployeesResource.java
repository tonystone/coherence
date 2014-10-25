/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.Employee;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/employees")
public interface EmployeesResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Employee> getEmployees (@QueryParam ("employeeId") Integer employeeId, @QueryParam ("locationId") Integer locationId, @QueryParam ("departmentId") Integer departmentId);

    @POST
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response postEmployee (Employee employee);

    @PUT
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response putEmployee (@QueryParam ("employeeId") Integer employeeId, Employee employee);

    @DELETE
    @Produces({"application/json", "application/xml" })
    Response deleteEmployee (@QueryParam ("employeeId") Integer employeeId);

}