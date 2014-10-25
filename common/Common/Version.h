//
// Created by Tony Stone on 2/14/14.
//
#ifndef __Version_H_
#define __Version_H_

#ifdef __cplusplus
#include <iostream>
#include <iomanip>
#endif  // __cplusplus
#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif  // __OBJC__

#if !defined(MG_INLINE)
#if defined(__GNUC__)
        #define MG_INLINE static __inline__ __attribute__((always_inline))
#elif defined(__cplusplus)
        #define MG_INLINE static inline
#endif
#endif

#if !defined(MG_CONST_REFERENCE)
#ifdef __cplusplus
    #define MG_CONST_REFERENCE(t) t const &
#else
    #define MG_CONST_REFERENCE(t) t
#endif
#endif

/** @type mg_version_type
*
* Represents the class or libraries version information.
*/
typedef struct  {
    unsigned int major;
    unsigned int minor;
    unsigned int build;
} mg_version_type;

#ifdef __cplusplus

namespace mg {

    /** @type Version
     *
     * Represents the class or libraries version information.
     */
    class Version : public mg_version_type {
    public:
        inline Version(unsigned int m1, unsigned int m2, unsigned int b) : mg_version_type({m1,m2,b}) {}
        inline ~Version() {}
    };

}   // namespace mg

#endif  // __cplusplus

#ifdef __OBJC__

    typedef mg_version_type MGVersion;

    /** @protocol MGVersionInfo
    *
    * If a class implements this protocol, you can query it for the libraries versionInfo information.
    */
    @protocol MGVersionInfo <NSObject>
    @required
        + (MGVersion) versionInfo;
    @end

    /**
    *  Make a MGVersion structure from the components.
    */
    MG_INLINE MGVersion MGMakeVersion(unsigned int major,unsigned int minor, unsigned int build) {
        MGVersion v; v.major = major; v.minor = minor; v.build = build;
        return v;
    }
#endif // __OBJC__

/**
*  Compare 2 mg_version_type types for equality
*/
MG_INLINE int mg_version_type_primitive_equal(MG_CONST_REFERENCE(mg_version_type) v1, MG_CONST_REFERENCE(mg_version_type) v2) {
    return (v1.major == v2.major && v1.minor == v2.minor && v1.build == v2.build);
}
#ifdef __cplusplus
    inline bool operator==(const mg_version_type & v1, const mg_version_type & v2) { return mg_version_type_primitive_equal(v1,v2); }
#endif // __cpluplus
#define MGVersionEqual(v1,v2) ((BOOL) mg_version_type_primitive_equal(v1,v2))

/**
*  Compare 2 mg_version_type types for non equality
*/
MG_INLINE int mg_version_type_primitive_not_equal(MG_CONST_REFERENCE(mg_version_type) v1, MG_CONST_REFERENCE(mg_version_type) v2) {
    return (v1.major != v2.major || v1.minor != v2.minor || v1.build != v2.build);
}
#ifdef __cplusplus
inline bool operator!=(const mg_version_type & v1, const mg_version_type & v2) { return mg_version_type_primitive_not_equal(v1,v2); }
#endif // __cpluplus
#define MGVersionNotEqual(v1,v2) ((BOOL) mg_version_type_primitive_not_equal(v1,v2))


/**
 *  Compare 2 mg_version_type types for greater than.
 */
MG_INLINE int mg_version_type_primitive_greater(MG_CONST_REFERENCE(mg_version_type) v1, MG_CONST_REFERENCE(mg_version_type) v2)  {

    if (v1.major > v2.major) return true;
    if (v1.major < v2.major) return false;

    if (v1.minor > v2.minor) return true;
    if (v1.minor < v2.minor) return false;

    if (v1.build > v2.build) return true;
    if (v1.build < v2.build) return false;

    return false;
}
#ifdef __cplusplus
    inline bool operator>(const mg_version_type & v1, const mg_version_type & v2)  { return mg_version_type_primitive_greater(v1,v2); }
#endif // __cpluplus
#define MGVersionGreaterThan(v1,v2) ((BOOL) mg_version_type_primitive_greater(v1,v2))

/**
 *  Compare 2 mg_version_type types for less than.
 */
MG_INLINE int mg_version_type_primitive_less(MG_CONST_REFERENCE(mg_version_type) v1, MG_CONST_REFERENCE(mg_version_type) v2) {

    if (v1.major < v2.major) return true;
    if (v1.major > v2.major) return false;

    if (v1.minor < v2.minor) return true;
    if (v1.minor > v2.minor) return false;

    if (v1.build < v2.build) return true;
    if (v1.build > v2.build) return false;

    return false;
}
#ifdef __cplusplus
    inline bool operator<(const mg_version_type  & v1, const mg_version_type & v2) { return mg_version_type_primitive_less(v1,v2); }
#endif // __cpluplus
#define MGVersionLessThan(v1,v2) ((BOOL) mg_version_type_primitive_less(v1,v2))

/**
*  Compare 2 mg_version_type types for equality or greater than.
*/
MG_INLINE int mg_version_type_primitive_greater_or_equal(MG_CONST_REFERENCE(mg_version_type) v1, MG_CONST_REFERENCE(mg_version_type) v2) {

    if (v1.major > v2.major) return true;
    if (v1.major < v2.major) return false;

    if (v1.minor > v2.minor) return true;
    if (v1.minor < v2.minor) return false;

    if (v1.build > v2.build) return true;
    if (v1.build < v2.build) return false;

    // All are equal so this is true
    return true;
}
#ifdef __cplusplus
    inline bool operator>=(const mg_version_type & v1, const mg_version_type & v2)  { return mg_version_type_primitive_greater_or_equal(v1,v2); }
#endif // __cpluplus
#define MGVersionGreaterThanOrEqual(v1,v2) ((BOOL) mg_version_type_primitive_greater_or_equal(v1,v2))

/**
*  Compare 2 mg_version_type types for equality or less than.
*/
MG_INLINE int mg_version_type_primitive_less_or_equal(MG_CONST_REFERENCE(mg_version_type) v1, MG_CONST_REFERENCE(mg_version_type) v2) {

    if (v1.major < v2.major) return true;
    if (v1.major > v2.major) return false;

    if (v1.minor < v2.minor) return true;
    if (v1.minor > v2.minor) return false;

    if (v1.build < v2.build) return true;
    if (v1.build > v2.build) return false;

    // If we get here, all are equal so we return true
    return true;
}
#ifdef __cplusplus
    inline bool operator<=(const mg_version_type  & v1, const mg_version_type & v2) { return mg_version_type_primitive_less_or_equal(v1,v2); }
#endif // __cpluplus
#define MGVersionLessThanOrEqual(v1,v2) ((BOOL) mg_version_type_primitive_less_or_equal(v1,v2))

#ifdef __OBJC__
/**
*  Creates a human readable string from a mg_version_type type.
*/
MG_INLINE NSString * MGStringFromVersion(MG_CONST_REFERENCE(mg_version_type) v) {
    return [NSString stringWithFormat: @"%u.%02u (%u)", v.major, v.minor, v.build];
}
#endif // __OBJC__

#ifdef __cplusplus
inline std::ostream & operator<<(std::ostream &os, const mg_version_type & v)  {
    return os << v.major << '.' << std::setfill('0') << std::setw(2) << v.minor << " (" << v.build << ')';
}
#endif // __cplusplus

#endif //__Version_H_
