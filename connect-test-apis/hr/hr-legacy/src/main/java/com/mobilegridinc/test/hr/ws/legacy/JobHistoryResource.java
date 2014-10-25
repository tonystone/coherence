/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.JobHistory;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.Date;
import java.util.List;

@Path("/jobhistory")
public interface JobHistoryResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<JobHistory> getJobHistory (@QueryParam ("employeeId") Integer employeeId, @QueryParam ("startDate") Date startDate);

    @POST
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response postJobHistory (@QueryParam ("employeeId") Integer employeeId, JobHistory jobHistory);

    @PUT
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response putJobHistory (@QueryParam ("employeeId") Integer employeeId, @QueryParam ("startDate") Date startDate, JobHistory jobHistory);

    @DELETE
    @Produces({"application/json", "application/xml" })
    Response deleteJobHistory (@QueryParam ("employeeId") Integer employeeId, @QueryParam ("startDate") Date startDate);

}