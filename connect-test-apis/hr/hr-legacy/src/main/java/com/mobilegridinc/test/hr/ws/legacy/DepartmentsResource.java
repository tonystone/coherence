/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.Department;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/departments")
public interface DepartmentsResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Department> getDepartments(@QueryParam("departmentId") Integer departmentId);

    @POST
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response postDepartment(Department department);

    @PUT
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response putDepartment(@QueryParam("departmentId") Integer departmentId, Department department);

    @DELETE
    @Produces({"application/json", "application/xml" })
    Response deleteDepartment (@QueryParam ("departmentId") Integer departmentId);

}