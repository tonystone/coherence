/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Country;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/regions/{regionId}/countries")
public interface RegionsRegionIdCountriesResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Country> listRegionCountries (@PathParam ("regionId") int regionId);

    @POST
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    Response insertRegionCountry (@PathParam ("regionId") int regionId, Country country);

    @GET
    @Produces({"application/json", "application/xml" })
    @Path("/{countryCode}")
    Country readRegionCountry (@PathParam ("regionId") int regionId, @PathParam ("countryCode") String countryCode);

    @PUT
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    @Path("/{countryCode}")
    Response updateRegionCountry (@PathParam ("regionId") int regionId, @PathParam ("countryCode") String countryCode, Country country);

    @DELETE
    @Produces({"application/json", "application/xml" })
    @Path("/{countryCode}")
    Response deleteRegionCountry (@PathParam ("regionId") int regionId, @PathParam ("countryCode") String countryCode);

}