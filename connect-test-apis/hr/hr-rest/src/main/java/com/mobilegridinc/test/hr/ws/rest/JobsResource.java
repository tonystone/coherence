/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Job;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/jobs")
public interface JobsResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Job> listJobs ();

    @POST
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    Response insertJob (Job job);

    @GET
    @Produces({"application/json", "application/xml" })
    @Path("/{jobId}")
    Job readJob (@PathParam ("jobId") int jobId);

    @PUT
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    @Path("/{jobId}")
    Response updateJob (@PathParam ("jobId") int jobId, Job job);

    @DELETE
    @Produces({"application/json", "application/xml" })
    @Path("/{jobId}")
    Response deleteJob (@PathParam ("jobId") int jobId);

}