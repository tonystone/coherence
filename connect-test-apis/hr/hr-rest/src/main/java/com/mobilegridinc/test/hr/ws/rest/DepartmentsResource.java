/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Department;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/departments")
public interface DepartmentsResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Department> listDepartments ();

    @POST
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    Response insertDepartment (Department department);

    @GET
    @Produces({"application/json", "application/xml" })
    @Path("/{departmentId}")
    Department readDepartment (@PathParam ("departmentId") int departmentId);

    @PUT
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    @Path("/{departmentId}")
    Response updateDepartment (@PathParam ("departmentId") int departmentId, Department department);

    @DELETE
    @Produces({"application/json", "application/xml" })
    @Path("/{departmentId}")
    Response deleteDepartment (@PathParam ("departmentId") int departmentId);

}