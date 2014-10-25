//
// Created by Tony Stone on 7/3/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#include "LogStream.h"
#include <iostream>
// Note: C++11 only
#include <iomanip>

//
// Create a null stream
// for when logging is off
//
struct NullStream : std::ostream {
    NullStream() : std::ios(0), std::ostream(0) {}
};

template <typename T>
NullStream & operator<<(NullStream & o, T const & x) { return o; }

static NullStream nullStream;

//
// Main implementation
//
mg::LogStream mg::LogStream::cout;

mg::LogStream::LogStream()  : mPrefix() {
    std::ios_base::sync_with_stdio(true);
}

mg::LogStream::LogStream(const char *prefix, LogLevel level) : mPrefix(std::string(prefix)), mLevel(level)  { }

mg::LogStream::LogStream(std::string &prefix, LogLevel level) : mPrefix(prefix), mLevel(level)  {}

mg::LogStream::LogStream(mg::LogStream const &param) {
    this->mPrefix = param.mPrefix;
    this->mLevel  = param.mLevel;
}

mg::LogStream &mg::LogStream::operator=(mg::LogStream const &param) {

    this->mPrefix = param.mPrefix;
    this->mLevel  = param.mLevel;

    return *this;
}

mg::LogStream::~LogStream() {}


void mg::LogStream::setLevel(LogLevel level) {
     mLevel = level;
}

std::ostream &mg::LogStream::writeHeader(mg::LogStream::LogLevel level) {
    if (level <= mLevel) {
        std::time_t time = std::time(nullptr);

        return std::cout << std::put_time(std::localtime(&time), "%Y-%m-%d %T") << ": " << levelStringValue(level) << ": " << mPrefix << ": ";
    }
    return nullStream;
}

std::string mg::LogStream::levelStringValue(mg::LogStream::LogLevel level) {
    switch (level) {
        case ERROR:   return "ERROR";
        case WARNING: return "WARN ";
        case INFO:    return "INFO ";
        case TRACE:   return "TRACE";
    }
    return "";
}
