

package com.mobilegridinc.connect.editor.desktop;


import org.osgi.framework.BundleActivator;
import org.osgi.framework.BundleContext;

import com.mobilegridinc.connect.editor.desktop.platform.PlatformInitialization;

import java.awt.*;

public class DesktopActivator implements BundleActivator {

    //Using a standard Java icon
//    private Icon optionIcon = UIManager.getIcon("FileView.computerIcon");

    @Override
    public void start (BundleContext context) throws Exception {
        String bundleName = this.getBundleName (context);

        System.out.println ("Starting " + bundleName + " [" + context.getBundle ().getVersion () + "]..." );

        PlatformInitialization.initialize();

        //Use the event dispatch thread for Swing components
        EventQueue.invokeLater(() -> {
            try {
                DesktopControllerImpl editor = new DesktopControllerImpl ();
                editor.getFrame().setVisible(true);

            } catch (Exception ex) {
                ex.printStackTrace();
                System.exit(0);
            }
        });

        System.out.println (bundleName + " [" + context.getBundle ().getVersion () + "] started.");
    }

    @Override
    public void stop (BundleContext context) throws Exception {
        String bundleName = this.getBundleName (context);

        System.out.println ("Stopping " + bundleName + " [" + context.getBundle ().getVersion () + "]...");

        System.out.println (bundleName + " [" + context.getBundle ().getVersion () + "] stopped.");
    }

    private String getBundleName(BundleContext context) {
        String bundleName = context.getBundle ().getHeaders ().get ("Bundle-Name");

        if (bundleName == null) {
            bundleName = context.getBundle ().getSymbolicName ();
        }
        return bundleName;
    }
}

