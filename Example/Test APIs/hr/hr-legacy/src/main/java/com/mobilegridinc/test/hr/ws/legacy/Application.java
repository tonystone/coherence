/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.test.hr.ws.legacy;

import javax.ws.rs.ApplicationPath;
import java.util.HashSet;
import java.util.Set;

/** HR REST Application
 *
 * Created by tony on 9/13/14.
 */
@ApplicationPath ("/")
public class Application extends javax.ws.rs.core.Application {

    @Override
    public Set<Class<?>> getClasses() {
        final Set<Class<?>> classes = new HashSet<> ();

        classes.add(RegionsResourceController.class);
        classes.add(CountriesResourceController.class);
        classes.add(DepartmentsResourceController.class);
        classes.add(JobsResourceController.class);
        classes.add(EmployeesResourceController.class);
        classes.add(JobHistoryResourceController.class);
        classes.add(LocationsResourceController.class);

        return classes;
    }
}
