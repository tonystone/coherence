//
// Created by Tony Stone on 2/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//


#ifndef __BinaryOArchiveImpl_HPP_
#define __BinaryOArchiveImpl_HPP_

#include "Access.hpp"
#include <streambuf>
#include <stdint.h>

namespace mg {
namespace serialization {

    template<class Archive, class Elem, class Tr>
    class BinaryOArchiveImpl {

    protected:
        inline BinaryOArchiveImpl(std::basic_streambuf<Elem, Tr> & bsb, unsigned int flags) : mStreamBuffer(bsb), mVersion(1) {}
        inline virtual ~BinaryOArchiveImpl () {}

        template <class T>
        inline bool serialize(Archive &archive, T &t) {
            mStreamBuffer.pubseekpos(0, std::ios_base::out);

            // Check that header is not present and buffer is empty
            // Write header
            uint32_t archiveIdentifier = 100;
            if (!this->saveBinary(&archiveIdentifier, sizeof(archiveIdentifier))) return (false);
            // Write version
            uint32_t version = mVersion;
            if (!this->saveBinary(&version, sizeof(version))) return (false);

            Access::serialize(archive, t, mVersion);
            
            return (true);
        }

        inline bool save(const std::size_t dataLen)
        {
            // Is the data value too large to store
            if (dataLen > UINT32_MAX) return (false);
            //
            // The length of the data is stored in a machine
            // independent fixed size.
            //
            // Note: This does not currently account for Endianness
            //
            //
            uint32_t        value = static_cast<uint32_t> (dataLen);
            std::streamsize size  = static_cast<std::streamsize> (sizeof(value));

            return (mStreamBuffer.sputn(reinterpret_cast<const char *>(&value), size) == size);
        }

        inline bool saveBinary(const void *data, const std::size_t dataLen)
        {
            std::streamsize size = static_cast<std::streamsize> (dataLen);

            return (mStreamBuffer.sputn(reinterpret_cast<const char *>(data), size) == size);
        }

        inline bool save(char const * str) {
            std::size_t len = static_cast<std::size_t>(std::strlen(str));
            if (this-save(len)) {
                return this->saveBinary(str, len);
            }
            return (false);
        }

        inline bool save(std::string const & str) {
            std::size_t len = static_cast<std::size_t>(str.size());
            if (this-save(len)) {
                return this->saveBinary(str.c_str(), len);
            }
            return (false);
        }

        inline bool save(std::time_t const & t) {
            std::size_t len = sizeof(t);
            if (this-save(len)) {
                return this->saveBinary(&t, len);
            }
            return (false);
        }

    private:
        std::basic_streambuf<Elem, Tr> & mStreamBuffer;
        unsigned int                     mVersion;
    };
}   // serialization
}   // mg


#endif //__BinaryOArchiveImpl_HPP_
