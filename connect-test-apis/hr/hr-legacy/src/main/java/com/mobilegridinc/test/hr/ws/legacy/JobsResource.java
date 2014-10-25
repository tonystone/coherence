/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.Job;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/jobs")
public interface JobsResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Job> getJobs (@QueryParam ("jobId") Integer jobId);

    @POST
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response postJob (Job job);

    @PUT
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response putJob (@QueryParam ("jobId") Integer jobId, Job job);

    @DELETE
    @Produces({"application/json", "application/xml" })
    Response deleteJob (@QueryParam ("jobId") Integer jobId);

}