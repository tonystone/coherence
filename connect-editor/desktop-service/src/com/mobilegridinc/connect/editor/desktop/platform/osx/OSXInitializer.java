package com.mobilegridinc.connect.editor.desktop.platform.osx;

import com.mobilegridinc.connect.editor.desktop.platform.PlatformInitializer;

import javax.swing.UIManager;

/**
 * Created by tony on 7/16/14.
 */
public class OSXInitializer implements PlatformInitializer {

    @Override
    public void initialize() {

        System.setProperty("apple.laf.useScreenMenuBar", "true");
        System.setProperty("com.apple.mrj.application.apple.menu.about.name", "Connect Editor");

        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        }
        catch (Exception e) {
            System.err.println("[error] "+ e.getMessage());
        }
    }
}
