/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.Location;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/locations")
public interface LocationsResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Location> getLocations (@QueryParam ("locationId") Integer locationId);

    @POST
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response postLocation (Location location);

    @PUT
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response putLocation (@QueryParam ("locationId") Integer locationId, Location location);

    @DELETE
    @Produces({"application/json", "application/xml" })
    Response deleteLocation (@QueryParam ("locationId") Integer locationId);

}