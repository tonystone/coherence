/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Employee;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/departments/{departmentId}/employees")
public interface DepartmentsDepartmentIdEmployeesResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Employee> listDepartmentEmployees (@PathParam ("departmentId") int departmentId);

    @POST
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml"})
    Response insertDepartmentEmployee (@PathParam ("departmentId") int departmentId, Employee employee);

    @GET
    @Produces({"application/json", "application/xml" })
    @Path("/{employeeId}")
    Employee readDepartmentEmployee (@PathParam ("departmentId") int departmentId, @PathParam ("employeeId") int employeeId);

    @PUT
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    @Path("/{employeeId}")
    Response updateDepartmentEmployee (@PathParam ("departmentId") int departmentId, @PathParam ("employeeId") int employeeId, Employee employee);

    @DELETE
    @Produces({"application/json", "application/xml" })
    @Path("/{employeeId}")
    Response deleteDepartmentEmployee (@PathParam ("departmentId") int departmentId, @PathParam ("employeeId") int employeeId);

}