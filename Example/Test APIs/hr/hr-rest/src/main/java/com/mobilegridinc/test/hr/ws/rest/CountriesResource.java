/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Country;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/countries")
public interface CountriesResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Country> listCountries ();

    @POST
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml"})
    Response insertCountry (Country country);

    @GET
    @Produces({"application/json", "application/xml" })
    @Path("/{countryCode}")
    Country readCountry (@PathParam ("countryCode") String countryCode);

    @PUT
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml"})
    @Path("/{countryCode}")
    Response updateCountry (@PathParam ("countryCode") String countryCode, Country country);

    @DELETE
    @Produces({"application/json", "application/xml" })
    @Path("/{countryCode}")
    Response deleteCountry (@PathParam ("countryCode") String countryCode);

}