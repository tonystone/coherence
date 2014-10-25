/*
 * Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
 */

package com.mobilegridinc.connect.editor.desktop;

import org.osgi.service.log.LogEntry;
import org.osgi.service.log.LogListener;


/**
 * Created by tony on 8/5/14.
 */
public interface ConsoleLog extends LogListener {

    @Override
    void logged (LogEntry logEntry);
}
