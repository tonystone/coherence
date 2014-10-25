/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Region;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/regions")
public interface RegionsResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Region> listRegions();

    @POST
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    Response insertRegion (Region region);

    @GET
    @Produces({"application/json", "application/xml" })
    @Path("/{regionId}")
    Region readRegion(@PathParam("regionId") int regionId);

    @PUT
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    @Path("/{regionId}")
    Response updateRegion (@PathParam ("regionId") int regionId, Region region);

    @DELETE
    @Produces({"application/json", "application/xml" })
    @Path("/{regionId}")
    Response deleteRegion(@PathParam("regionId") int regionId);

}