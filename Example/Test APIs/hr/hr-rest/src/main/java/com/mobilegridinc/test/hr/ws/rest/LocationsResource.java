/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.rest;

import com.mobilegridinc.test.hr.persistence.Location;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/locations")
public interface LocationsResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Location> listLocations ();

    @POST
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    Response insertLocation (Location location);

    @GET
    @Produces({"application/json", "application/xml" })
    @Path("/{locationId}")
    Location readLocation (@PathParam ("locationId") int locationId);

    @PUT
    @Consumes({"application/json", "application/xml"})
    @Produces({"application/json", "application/xml" })
    @Path("/{locationId}")
    Response updateLocation (@PathParam ("locationId") int locationId, Location location);

    @DELETE
    @Produces({"application/json", "application/xml" })
    @Path("/{locationId}")
    Response deleteLocation (@PathParam ("locationId") int locationId);

}