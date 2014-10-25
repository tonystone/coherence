/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.Location;
import com.mobilegridinc.test.hr.persistence.PersistenceManager;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;
import java.util.HashMap;
import java.util.List;

public class LocationsResourceController implements LocationsResource {

    private PersistenceManager<Location> persistenceManager = null;
    private UriInfo uriInfo                                  = null;

    public LocationsResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Location.class);
    }

    @Override
    public List<Location> getLocations (Integer locationId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        if (locationId != null)
            criteria.put ("locationId", locationId);

        return persistenceManager.list (criteria);
    }

    @Override
    public Response postLocation (Location location) {

        Response response = null;

        Location newCountry = persistenceManager.insert (location);

        if (newCountry != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.queryParam ("locationId", newCountry.getLocationId ()).build ();

            response = Response.created (locationUri).entity (newCountry).build ();
        }
        return response;
    }

    @Override
    public Response putLocation (Integer locationId, Location location) {

        Location updatedCountry = persistenceManager.update (location);

        if (updatedCountry == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteLocation (Integer locationId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        if (locationId != null)
            criteria.put ("locationId", locationId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }
}