//
// Created by Tony Stone on 8/22/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//


#ifndef __Connect_H_
#define __Connect_H_

namespace mg {

    class Connect {

        public:
            class Options {

                public:
                    Options ();
                    virtual ~Options();

                    unsigned int contextLimit();
                    void         contextLimit(unsigned int newValue);

                    bool takeOverCoreData();
                    void takeOverCoreData(bool newValue);

                private:
                    unsigned int mContextLimit;
                    struct {
                        unsigned int takeOverCoreData:1;
                        unsigned int reserved:31;
                    } mFlags;
            };

        public:
            Connect(Options & options);
            virtual ~Connect();

        private:
            Options mOptions;

    };

}   // namespace mg

#endif //__Connect_H_
