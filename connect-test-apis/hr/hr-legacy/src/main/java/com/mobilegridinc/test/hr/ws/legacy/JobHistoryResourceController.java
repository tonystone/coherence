/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.JobHistory;
import com.mobilegridinc.test.hr.persistence.PersistenceManager;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

public class JobHistoryResourceController implements JobHistoryResource {

    private PersistenceManager<JobHistory> persistenceManager = null;
    private UriInfo uriInfo                                  = null;

    public JobHistoryResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (JobHistory.class);
    }

    @Override
    public List<JobHistory> getJobHistory (Integer employeeId, Date startDate) {

        HashMap<String, Object> criteria = new HashMap<> (2);

        if (employeeId != null)
            criteria.put ("employeeId", employeeId);

        if (startDate != null)
            criteria.put ("startDate", startDate);

        return persistenceManager.list (criteria);
    }

    @Override
    public Response postJobHistory (Integer employeeId, JobHistory jobHistory) {

        Response response = null;

        JobHistory newCountry = persistenceManager.insert (jobHistory);

        if (newCountry != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.queryParam ("startDate", newCountry.getStartDate ()).build ();

            response = Response.created (locationUri).entity (newCountry).build ();
        }
        return response;
    }

    @Override
    public Response putJobHistory (Integer employeeId, Date startDate, JobHistory jobHistory) {

        JobHistory updatedCountry = persistenceManager.update (jobHistory);

        if (updatedCountry == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteJobHistory (Integer employeeId, Date startDate) {

        HashMap<String, Object> criteria = new HashMap<> (2);

        if (employeeId != null)
            criteria.put ("employeeId", employeeId);

        if (startDate != null)
            criteria.put ("startDate", startDate);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }
}