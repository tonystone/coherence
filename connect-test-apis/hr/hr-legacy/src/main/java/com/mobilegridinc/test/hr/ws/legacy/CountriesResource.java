/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.Country;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/countries")
public interface CountriesResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Country> getCountries (@QueryParam ("regionId") Integer regionId, @QueryParam ("countryCode") String countryCode);

    @POST
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response postCountry(Country country);

    @PUT
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response putCountry (@QueryParam ("countryCode") String countryCode, Country country);

    @DELETE
    @Produces({"application/json", "application/xml" })
    Response deleteCountry (@QueryParam ("regionId") Integer regionId, @QueryParam ("countryCode") String countryCode);

}