/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.rest;

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

/** Jobs REST Controller
 *
 * Created by tony on 9/9/14.
 */

public class JobsResourceController implements JobsResource {

    private PersistenceManager<Job> persistenceManager = null;
    private UriInfo uriInfo                                = null;

    public JobsResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Job.class);
    }

    @Override
    public List<Job> listJobs () {
        return persistenceManager.list ();
    }

    @Override
    public Response insertJob (Job job) {

        Response response = null;

        Job newJob = persistenceManager.insert (job);

        if (newJob != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.path ("{jobId}").build (newJob.getJobId ());

            response = Response.created (locationUri).entity (newJob).build ();
        }
        return response;
    }

    @Override
    public Job readJob (int jobId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("jobId", jobId);

        Job job = persistenceManager.read (criteria);

        if (job == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return job;
    }

    @Override
    public Response updateJob (@SuppressWarnings ("unused") int jobId, Job job) {

        Job updatedJob = persistenceManager.update (job);

        if (updatedJob == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteJob (int jobId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("jobId", jobId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

}
