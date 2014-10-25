//
// Created by Tony Stone on 2/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//


#ifndef __BinaryIArchiveImpl_HPP_
#define __BinaryIArchiveImpl_HPP_

#include "Access.hpp"
#include <streambuf>
#include <stdint.h>

namespace mg {
namespace serialization {

    template<class Archive, class Elem, class Tr>
    class BinaryIArchiveImpl {

    protected:
        inline BinaryIArchiveImpl(std::basic_streambuf<Elem, Tr> & bsb, unsigned int flags) : mStreamBuffer(bsb), mVersion(0) {}
        inline virtual ~BinaryIArchiveImpl () {}

        template <class T>
        inline bool serialize(Archive &archive, T &t) {
            mStreamBuffer.pubseekpos(0, std::ios_base::in);
            
            // Check that header is not present and buffer is empty
            // Load header
            uint32_t archiveIdentifier = 0;
            if (!this->loadBinary(&archiveIdentifier, sizeof(archiveIdentifier))) return (false);
            
            // Validate that header is correct
            if (archiveIdentifier != 100) return (false);

            // Load version
            uint32_t version = 0;
            if (!this->loadBinary(&version, sizeof(version))) return (false);

            Access::serialize(archive, t, mVersion);
            
            return (true);
        }

        inline bool load(std::size_t & dataLen)
        {
            //
            // The length of the data is stored in a machine
            // independent fixed size.
            //
            // Note: This does not currently account for Endianness
            //
            //
            uint32_t len = 0;

            std::streamsize lenSize  = static_cast<std::streamsize> (sizeof(len));

            if (mStreamBuffer.sgetn(reinterpret_cast<char *>(&len), lenSize) != lenSize) return (false);

            dataLen = static_cast<std::size_t>(len);

            return (true);
        }

        inline bool loadBinary(void *data, const std::size_t dataLen)
        {
            std::streamsize size = static_cast<std::streamsize> (dataLen);

            return (mStreamBuffer.sgetn(reinterpret_cast<char *>(data), size) == size);
        }

        inline bool load(char * str) {
            std::size_t len = 0;
            if (this-load(len)) {
                if (this->loadBinary(str, len)) {
                    str[len] = '\0';
                }
            }
            return (false);
        }

        inline bool load(std::string & str) {
            std::size_t len = 0;
            if (this-load(len)) {
                str.resize(len);
                return this->loadBinary(&(*str.begin()), len);
            }
            return (false);
        }

        inline bool load(std::time_t & t) {
            std::size_t len = 0;
            if (this->load(len)) {
                return this->loadBinary(&t, len);
            }
            return (false);
        }

    private:
        std::basic_streambuf<Elem, Tr> & mStreamBuffer;
        unsigned int                     mVersion;
    };
}   // serialization
}   // mg


#endif //__BinaryIArchiveImpl_HPP_
