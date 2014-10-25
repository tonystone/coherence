//
// Created by Tony Stone on 2/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//


#ifndef __BinaryOArchive_HPP_
#define __BinaryOArchive_HPP_

#include "BinaryOArchiveImpl.hpp"
#include <string>
#include <ctime>

namespace mg {
namespace serialization {

    class BinaryOArchive : protected BinaryOArchiveImpl<BinaryOArchive, std::streambuf::char_type, std::streambuf::traits_type> {

    public:
        inline BinaryOArchive(std::streambuf & bsb, unsigned int flags = 0) : BinaryOArchiveImpl<BinaryOArchive, std::streambuf::char_type, std::streambuf::traits_type>(bsb, flags) {}
        inline virtual ~BinaryOArchive () {}

        template <class T>
        inline BinaryOArchive & operator<<(T & t) {
            this->serialize(*this, t);  return *this;
        }
        inline BinaryOArchive & operator&(std::string const & str) {
            this->save(str);  return *this;
        }
        inline BinaryOArchive & operator&(std::time_t const & t) {
            this->save(t); return *this;
        }
    };
}   // serialization
}   // mg


#endif //__BinaryOArchive_HPP_
