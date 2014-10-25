//
// Created by Tony Stone on 8/22/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#include "Connect.hpp"

//
// mg::Connect
//
mg::Connect::Connect(mg::Connect::Options &options) {
    mOptions = options;
}

mg::Connect::~Connect() {

}

//
// mg::Connect::Options
//

mg::Connect::Options::Options() {
    mFlags = {0};
}

mg::Connect::Options::~Options() {

}

unsigned int mg::Connect::Options::contextLimit() {
    return mContextLimit;
}

bool mg::Connect::Options::takeOverCoreData() {
    return (bool) mFlags.takeOverCoreData;
}

 void mg::Connect::Options::contextLimit(unsigned int newValue)  {
    mContextLimit = newValue;
}

void mg::Connect::Options::takeOverCoreData(bool newValue) {
   mFlags.takeOverCoreData = (unsigned int) newValue;
}
