package com.mobilegridinc.connect.editor.desktop.platform.linux;

import com.mobilegridinc.connect.editor.desktop.platform.PlatformInitializer;

import javax.swing.*;

/**
 * Created by tony on 7/16/14.
 */
public class LinuxInitializer implements PlatformInitializer {

    @Override
    public void initialize() {

        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        }
        catch (Exception e) {
            System.err.println("[error] "+ e.getMessage());
        }
    }
}
