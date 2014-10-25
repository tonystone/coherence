//
// Created by Tony Stone on 2/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//


#ifndef __Access_HPP_
#define __Access_HPP_

namespace mg {
namespace serialization {

    class Access {

    public:
        template<class Archive, class T>
        friend inline void serialize(Archive & ar, T & t, const unsigned int version);

        /* User access calls
         *
         * These are used to access the users class implementations
         */
        template<class Archive, class T>
        static void serialize(Archive & ar, T & t, const unsigned int version ) {
            t.serialize(ar, version);
        }
        template<class T>
        static void destroy(T * t) // const appropriate here?
        {
            delete const_cast<T *>(t);
        }
        /* Default is inplace invocation of default constructor
         * Note the :: before the placement new. Required if the
         *  class doesn't have a class-specific placement new defined.
         */
        template<class T>
        static void construct(T * t) {
            ::new(t)T;
        }
        template<class T, class U>
        static T & cast_reference(U & u){
            return static_cast<T &>(u);
        }
        template<class T, class U>
        static T * cast_pointer(U * u){
            return static_cast<T *>(u);
        }
    };

}   // serialization
}   // mg


#endif //__Access_HPP_
