//
// Created by Tony Stone on 6/22/15.
//

#import <Foundation/Foundation.h>


/**
* @interface       CCConfiguration
*
* @brief       Protocol that defines the callbacks on subclasses of CCConfiguration.
*
* @author      Tony Stone
* @date        6/23/15
*/
@protocol CCConfiguration <NSObject>

    @optional

    /**
    *  This method should return a dictionary keyed by property name
    *  with the values for defaults in the instance. Value types must
    *  be of the correct type for the property or be able to be converted
    *  to the correct type.
    */
    - (NSDictionary *) defaults;

    /**
     *  This method should return the name of the main bundle dictionary
     *  key to search for the configuration option keys.
     *
     * @default TCCConfiguration
     */
    - (NSString *) bundleKey;

@end



/**
* @class       CCConfiguration
*
* @brief       Main configuration subclass and factory class.
*
* @note        This class may be subclassed in order to supply
*              defaults and other behaviour of your choice.
*
* @author      Tony Stone
* @date        6/23/15
*/
@interface CCConfiguration : NSObject <CCConfiguration>

    /**
    *  Creates an implementation and instance of
    *  configuration instance for the protocol
    *  specified.
    *
    *  @warning Do not override this method if you sub class.
    */
    + (id) configurationForProtocol: (Protocol *)aProtocol;

    /**
    *   Creates an implementation and instance of
    *   configuration instance for the protocol
    *   specified and uses the defaults as initial
    *   values.
    */
    + (id) configurationForProtocol: (Protocol *)aProtocol defaults: (NSDictionary *) defaults;

@end

