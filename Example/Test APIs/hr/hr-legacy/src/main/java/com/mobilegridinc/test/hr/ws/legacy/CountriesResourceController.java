/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

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

public class CountriesResourceController implements CountriesResource {

    private PersistenceManager<Country> persistenceManager = null;
    private UriInfo uriInfo                                  = null;

    public CountriesResourceController (@Context UriInfo uriInfo) {
        this.uriInfo  = uriInfo;
        this.persistenceManager = new PersistenceManager<> (Country.class);
    }

    @Override
    public List<Country> getCountries (Integer regionId, String countryCode) {

        HashMap<String, Object> criteria = new HashMap<> (2);

        if (regionId != null)
            criteria.put ("regionId", regionId);

        if (countryCode != null)
            criteria.put ("countryCode", countryCode);

        return persistenceManager.list (criteria);
    }

    @Override
    public Response postCountry(Country country) {

        Response response = null;

        Country newCountry = persistenceManager.insert (country);

        if (newCountry != null) {
            UriBuilder uriBuilder =  uriInfo.getAbsolutePathBuilder ();

            URI locationUri = uriBuilder.queryParam ("countryCode", newCountry.getCountryCode ()).build ();

            response = Response.created (locationUri).entity (newCountry).build ();
        }
        return response;
    }

    @Override
    public Response putCountry (String countryCode, Country country) {

        Country updatedCountry = persistenceManager.update (country);

        if (updatedCountry == null) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

    @Override
    public Response deleteCountry (Integer regionId, String countryCode) {

        HashMap<String, Object> criteria = new HashMap<> (2);

        if (regionId != null)
            criteria.put ("regionId", regionId);

        if (countryCode != null)
            criteria.put ("countryCode", countryCode);

        int rowCount = persistenceManager.delete (criteria);

        if (rowCount == 0) {
            throw new WebApplicationException (404);    // Not Found
        }
        return Response.noContent ().build ();
    }

}