/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Country;
import com.mobilegridinc.test.hr.persistence.PersistenceManager;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.UriBuilder;
import javax.ws.rs.core.UriInfo;
import java.net.URI;
import java.util.HashMap;
import java.util.List;

/** Countries REST Controller
 *
 * Created by tony on 9/9/14.
 */
public class RegionsRegionIdCountriesResourceController implements RegionsRegionIdCountriesResource {

    private PersistenceManager<Country> persistenceManager = null;
    private UriInfo uriInfo                                = null;

    public RegionsRegionIdCountriesResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Country.class);
    }

    @Override
    public List<Country> listRegionCountries (int regionId) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("regionId", regionId);

        return persistenceManager.list (criteria);
    }

    @Override
    public Response insertRegionCountry (int regionId, Country country) {

        if (regionId != country.getRegionId ()) {
            throw new WebApplicationException (400);    // Bad Request
        }

        Response response = null;

        Country newCountry = persistenceManager.insert (country);

        if (newCountry != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.path ("{countryCode}").build (newCountry.getCountryCode ());

            response = Response.created (locationUri).entity (newCountry).build ();
        }
        return response;
    }

    @Override
    public Country readRegionCountry (int regionId, String countryCode) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("countryCode", countryCode);

        Country country = persistenceManager.read (criteria);

        if (regionId != country.getRegionId ()) {
            throw new WebApplicationException (400);    // Bad Request
        }

        if (country == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return country;
    }

    @Override
    public Response updateRegionCountry (int regionId, String countryCode, Country country) {

        if (regionId != country.getRegionId () || countryCode != country.getCountryCode () ) {
            throw new WebApplicationException (400);    // Bad Request
        }

        Country updatedDepartmentCountry = persistenceManager.update (country);

        if (updatedDepartmentCountry == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteRegionCountry (int regionId, String countryCode)  {

        HashMap<String, Object> criteria = new HashMap<> (2);

        criteria.put ("regionId"   , regionId);
        criteria.put ("countryCode", countryCode);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }
}
