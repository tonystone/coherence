/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.rest;

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

/** Locations REST Controller
 *
 * Created by tony on 9/9/14.
 */
public class LocationsResourceController implements LocationsResource {

    private PersistenceManager<Location> persistenceManager = null;
    private UriInfo uriInfo                                = null;

    public LocationsResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Location.class);
    }

    @Override
    public List<Location> listLocations () {
        return persistenceManager.list ();
    }

    @Override
    public Response insertLocation (Location location) {

        Response response = null;

        Location newLocation = persistenceManager.insert (location);

        if (newLocation != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.path ("{locationId}").build (newLocation.getLocationId ());

            response = Response.created (locationUri).entity (newLocation).build ();
        }
        return response;
    }

    @Override
    public Location readLocation (int locationId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("locationId", locationId);

        Location location = persistenceManager.read (criteria);

        if (location == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return location;
    }

    @Override
    public Response updateLocation (@SuppressWarnings ("unused") int locationId, Location location) {

        Location updatedLocation = persistenceManager.update (location);

        if (updatedLocation == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteLocation (int locationId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("locationId", locationId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

}
