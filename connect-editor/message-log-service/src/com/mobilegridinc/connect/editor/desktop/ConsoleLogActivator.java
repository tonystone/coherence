

/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.connect.editor.desktop;


import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;
import org.osgi.service.log.LogReaderService;
import org.osgi.framework.ServiceReference;

public class ConsoleLogActivator implements BundleActivator {

    //Using a standard Java icon
//    private Icon optionIcon = UIManager.getIcon("FileView.computerIcon");

    private ConsoleLogController messageLogController = new ConsoleLogController ();

    @Override
    public void start (BundleContext context) throws Exception {
        String bundleName = this.getBundleName (context);
        System.out.println ("Starting " + bundleName + " [" + context.getBundle ().getVersion () + "]..." );

        context.registerService (ConsoleLog.class, messageLogController, null);

        ServiceReference ref = context.getServiceReference(LogReaderService.class.getName());
        if (ref != null)
        {
            LogReaderService reader = (LogReaderService) context.getService(ref);
            reader.addLogListener(messageLogController);
        }

        System.out.println (bundleName + " [" + context.getBundle ().getVersion () + "] started.");
    }

    @Override
    public void stop (BundleContext context) throws Exception {
        String bundleName = this.getBundleName (context);

        System.out.println ("Starting " + bundleName + " [" + context.getBundle ().getVersion () + "]..." );

        System.out.println (bundleName + " [" + context.getBundle ().getVersion () + "] started.");
    }

    private String getBundleName(BundleContext context) {
        String bundleName = context.getBundle ().getHeaders ().get ("Bundle-Name");

        if (bundleName == null) {
            bundleName = context.getBundle ().getSymbolicName ();
        }
        return bundleName;
    }

}

