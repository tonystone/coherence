/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.Job;
import com.mobilegridinc.test.hr.persistence.PersistenceManager;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;
import java.util.HashMap;
import java.util.List;

public class JobsResourceController implements JobsResource {

    private PersistenceManager<Job> persistenceManager = null;
    private UriInfo uriInfo                                  = null;

    public JobsResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Job.class);
    }

    @Override
    public List<Job> getJobs (Integer jobId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        if (jobId != null)
            criteria.put ("jobId", jobId);

        return persistenceManager.list (criteria);
    }

    @Override
    public Response postJob (Job job) {

        Response response = null;

        Job newCountry = persistenceManager.insert (job);

        if (newCountry != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.queryParam ("jobId", newCountry.getJobId ()).build ();

            response = Response.created (locationUri).entity (newCountry).build ();
        }
        return response;
    }

    @Override
    public Response putJob (Integer jobId, Job job) {

        Job updatedCountry = persistenceManager.update (job);

        if (updatedCountry == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteJob (Integer jobId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        if (jobId != null)
            criteria.put ("jobId", jobId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }
}