package com.mobilegridinc.connect.editor.desktop.platform;


import com.mobilegridinc.connect.editor.desktop.platform.linux.LinuxInitializer;
import com.mobilegridinc.connect.editor.desktop.platform.osx.OSXInitializer;
import com.mobilegridinc.connect.editor.desktop.platform.win.WinInitializer;

import java.util.Locale;

/**
 * Created by tony on 7/16/14.
 */
public class PlatformInitialization {

    public static final class OsCheck {
        /**
         * types of Operating Systems
         */
        public enum OSType {
            Windows, MacOS, Linux, Other
        };

        // cached result of OS detection
        protected static OSType detectedOS;

        /**
         * detect the operating system from the os.name System property and cache
         * the result
         *
         * @returns - the operating system detected
         */
        public static OSType getOperatingSystemType() {
            if (detectedOS == null) {
                String OS = System.getProperty("os.name", "generic").toLowerCase(Locale.ENGLISH);
                if (OS.contains("mac") || OS.contains("darwin")) {
                    detectedOS = OSType.MacOS;
                } else if (OS.contains("win")) {
                    detectedOS = OSType.Windows;
                } else if (OS.contains("nux")) {
                    detectedOS = OSType.Linux;
                } else {
                    detectedOS = OSType.Other;
                }
                System.out.println("Detected OS: " + OS);
            }
            return detectedOS;
        }
    }

    static public void initialize () {

        PlatformInitializer platformInitializer = null;

        switch (OsCheck.getOperatingSystemType()) {
            case Windows:
                platformInitializer = new WinInitializer();
                break;
            case MacOS:
                platformInitializer = new OSXInitializer();
                break;
            case Linux:
                platformInitializer = new LinuxInitializer();
                break;
            case Other:
                break;
        }

        if (platformInitializer != null) {
            platformInitializer.initialize();
        }
    }
}
