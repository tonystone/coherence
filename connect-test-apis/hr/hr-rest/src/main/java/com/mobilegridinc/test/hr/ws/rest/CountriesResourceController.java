/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Country;
import com.mobilegridinc.test.hr.persistence.PersistenceManager;

import javax.annotation.security.PermitAll;
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
@PermitAll
public class CountriesResourceController implements CountriesResource {

    private PersistenceManager<Country> persistenceManager = null;
    private UriInfo uriInfo                                = null;

    public CountriesResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Country.class);
    }

    @Override
    public List<Country> listCountries () {
        return persistenceManager.list ();
    }

    @Override
    public Response insertCountry (Country country) {

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
    public Country readCountry (String countryCode) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("countryCode", countryCode);

        Country region = persistenceManager.read (criteria);

        if (region == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return region;
    }

    @Override
    public Response updateCountry (@SuppressWarnings ("unused") String countryCode, Country country) {

        Country updatedCountry = persistenceManager.update (country);

        if (updatedCountry == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteCountry (String countryCode) {

        HashMap<String, Object> criteria = new HashMap<> (1);

        criteria.put ("countryCode", countryCode);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }


}
