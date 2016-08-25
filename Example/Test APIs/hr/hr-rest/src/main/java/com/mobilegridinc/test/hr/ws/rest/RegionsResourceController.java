/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.PersistenceManager;
import com.mobilegridinc.test.hr.persistence.Region;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;
import java.util.HashMap;
import java.util.List;

/** Regions REST Controller
 *
 * Created by tony on 9/9/14.
 */
public class RegionsResourceController  implements RegionsResource {

    private PersistenceManager<Region> persistenceManager = null;
    private UriInfo uriInfo                                = null;

    public RegionsResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Region.class);
    }

    @Override
    public List<Region> listRegions () {
        return persistenceManager.list ();
    }

    @Override
    public Response insertRegion (Region region) {

        Response response = null;

        Region newRegion = persistenceManager.insert (region);

        if (newRegion != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.path ("{regionId}").build (newRegion.getRegionId ());

            response = Response.created (locationUri).entity (newRegion).build ();
        }
        return response;
    }

    @Override
    public Region readRegion (int regionId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("regionId", regionId);

        Region region = persistenceManager.read (criteria);

        if (region == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return region;
    }

    @Override
    public Response updateRegion (@SuppressWarnings ("unused") int regionId, Region region) {

        Region updatedRegion = persistenceManager.update (region);

        if (updatedRegion == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteRegion (int regionId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("regionId", regionId);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

}
