/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Employee;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/employees")
public interface EmployeesResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Employee> listEmployees ();

    @POST
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    Response insertEmployee (Employee employee);

    @GET
    @Produces({"application/json", "application/xml" })
    @Path("/{employeeId}")
    Employee readEmployee (@PathParam ("employeeId") int employeeId);

    @PUT
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    @Path("/{employeeId}")
    Response updateEmployee (@PathParam ("employeeId") int employeeId, Employee employee);

    @DELETE
    @Produces({"application/json", "application/xml" })
    @Path("/{employeeId}")
    Response deleteEmployee (@PathParam ("employeeId") int employeeId);

}