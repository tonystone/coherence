/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.JobHistory;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.Date;
import java.util.List;

@Path("/employees/{employeeId}/jobhistory")
public interface EmployeesEmployeeIdJobHistoryResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<JobHistory> listEmployeeJobHistory (@PathParam ("employeeId") int employeeId);

    @POST
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    Response insertEmployeeJobHistory (@PathParam ("employeeId") int employeeId, JobHistory jobHistory);

    @GET
    @Produces({"application/json", "application/xml" })
    @Path("/{startDate}")
    JobHistory readEmployeeJobHistory (@PathParam ("employeeId") int employeeId, @PathParam ("startDate") Date startDate);

    @PUT
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    @Path("/{startDate}")
    Response updateEmployeeJobHistory (@PathParam ("employeeId") int employeeId, @PathParam ("startDate") Date startDate, JobHistory jobHistory);

    @DELETE
    @Produces({"application/json", "application/xml" })
    @Path("/{startDate}")
    Response deleteEmployeeJobHistory (@PathParam ("employeeId") int employeeId, @PathParam ("startDate") Date startDate);

}