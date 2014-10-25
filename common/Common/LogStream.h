//
// Created by Tony Stone on 7/3/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//


#ifndef __ConsoleLog_H_
#define __ConsoleLog_H_

#include <string>
#include <iostream>

namespace mg {

    /** @interface LogStream
    *
    */
    class LogStream {

    public:
        enum LogLevel {ERROR = 0, WARNING = 1, INFO = 2, TRACE = 3};

        static LogStream cout;

    public:
        LogStream();
        explicit LogStream (const char * prefix, LogLevel level = INFO);
        explicit LogStream (std::string & prefix, LogLevel level = INFO);

        virtual ~LogStream();

        // You can copy this object
        LogStream(const LogStream&);
        LogStream& operator =(const LogStream&);

        void setLevel(LogLevel level);

        template<class T>
        std::ostream & operator<<(T & t) {
            return writeHeader(INFO) << t;
        }

        std::ostream & operator<<(LogLevel level) {
            return writeHeader(level);
        }

    private:
        std::ostream & writeHeader (LogLevel level);
        std::string levelStringValue(LogLevel level);

    private:
        std::string mPrefix;
        LogLevel    mLevel;
    };

}   // namespace mg

#endif //__ConsoleLog_H_
