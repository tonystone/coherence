/**
 *   CCConfiguration.h
 *
 *   Copyright 2015 The Climate Corporation
 *   Copyright 2015 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 6/22/15.
 */
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

