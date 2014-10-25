/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.Region;
import com.mobilegridinc.test.hr.persistence.PersistenceManager;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;
import java.util.HashMap;
import java.util.List;

public class RegionsResourceController implements RegionsResource {

    private PersistenceManager<Region> persistenceManager = null;
    private UriInfo uriInfo                                  = null;

    public RegionsResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Region.class);
    }

    @Override
    public List<Region> getRegions (Integer regionId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        if (regionId != null)
            criteria.put ("regionId", regionId);

        return persistenceManager.list (criteria);
    }

    @Override
    public Response postRegion (Region region) {

        Response response = null;

        Region newCountry = persistenceManager.insert (region);

        if (newCountry != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI regionUri = uriBuilder.queryParam ("regionId", newCountry.getRegionId ()).build ();

            response = Response.created (regionUri).entity (newCountry).build ();
        }
        return response;
    }

    @Override
    public Response putRegion (Integer regionId, Region region) {

        Region updatedCountry = persistenceManager.update (region);

        if (updatedCountry == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteRegion (Integer regionId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        if (regionId != null)
            criteria.put ("regionId", regionId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }
    
    
}