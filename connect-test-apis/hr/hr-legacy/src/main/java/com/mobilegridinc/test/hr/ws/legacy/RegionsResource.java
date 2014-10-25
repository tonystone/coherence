/**
 * Created by Apache CXF WadlToJava code generator
**/
package com.mobilegridinc.test.hr.ws.legacy;

import com.mobilegridinc.test.hr.persistence.Region;

import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import java.util.List;

@Path("/regions")
public interface RegionsResource {

    @GET
    @Produces({"application/json", "application/xml" })
    List<Region> getRegions(@QueryParam("regionId") Integer regionId);

    @POST
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response postRegion (Region region);

    @PUT
    @Consumes({"application/json", "application/xml" })
    @Produces({"application/json", "application/xml" })
    Response putRegion (@QueryParam ("regionId") Integer regionId, Region region);

    @DELETE
    @Produces({"application/json", "application/xml" })
    Response deleteRegion (@QueryParam ("regionId") Integer regionId);

}