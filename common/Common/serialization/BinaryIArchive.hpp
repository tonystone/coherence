//
// Created by Tony Stone on 2/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//


#ifndef __BinaryIArchive_HPP_
#define __BinaryIArchive_HPP_

#include "BinaryIArchiveImpl.hpp"
#include <string>
#include <ctime>

namespace mg {
namespace serialization {

    class BinaryIArchive : protected BinaryIArchiveImpl<BinaryIArchive, std::streambuf::char_type, std::streambuf::traits_type> {

    public:
        inline BinaryIArchive(std::streambuf & bsb, unsigned int flags = 0) : BinaryIArchiveImpl<BinaryIArchive, std::streambuf::char_type, std::streambuf::traits_type>(bsb, flags) {}
        inline virtual ~BinaryIArchive () {}

        template <class T>
        inline BinaryIArchive & operator>>(T & t) {
            this->serialize(*this, t);  return *this;
        }
        inline BinaryIArchive & operator&(std::string & str) {
            this->load(str);  return *this;
        }
        inline BinaryIArchive & operator&(std::time_t & t) {
            this->load(t); return *this;
        }
    };
}   // serialization
}   // mg


#endif //__BinaryIArchive_HPP_
