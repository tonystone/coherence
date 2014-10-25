package com.mobilegridinc.connect.editor.desktop;

import org.osgi.service.log.LogEntry;

/**
 * Created by tony on 7/17/14.
 */
public class ConsoleLogController implements ConsoleLog {

    @Override
    public void logged (LogEntry logEntry) {

        System.out.println(logEntry.getMessage());
    }

}
