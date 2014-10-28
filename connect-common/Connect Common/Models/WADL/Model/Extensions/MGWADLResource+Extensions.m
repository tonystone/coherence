//
// Created by Tony Stone on 7/13/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLResource+Extensions.h"
#import "MGWADLResources.h"
#import "MGWADLParam.h"

@implementation MGWADLResource (Extensions)

    - (NSString *)fullPath {
        return nil;
    }

    - (NSString *)fullRelativePath {
        /*
            http://www.w3.org/Submission/wadl/#x3-38000C

            The URI for a resource element is obtained using the following rules:

                (1) Set identifier equal to the URI computed (using this process) for the parent element (resource or resources)
                (2) If identifier doesn't end with a '/' then append a '/' character to identifier
                (3) Substitute the values of any URI template parameters into the value of the path attribute
                (4) Append the value obtained in the previous step to identifier
                (5) For each child param element (see section 2.12), in document order, that has a value of 'matrix' for its style attribute, append a representation of the parameter value to identifier according to the following rules:
                    * Non-boolean matrix parameters are represented as: ';' name '=' value
                    * Boolean matrix parameters are represented as: ';' name when value is true and are omitted from identifier when value is false

                where name is the value of the param element's name attribute and value is the runtime value of the parameter.
         */

        NSMutableString * fullRelativePath = [[NSMutableString alloc] init];
        id                parent           = [self parent];

        // (1)
        if (parent) {
            if ([parent isKindOfClass: [MGWADLResource class]]) {
                [fullRelativePath appendString: [(MGWADLResource *) parent fullRelativePath]];
            } else if ([parent isKindOfClass: [MGWADLResources class]]) {
                [fullRelativePath appendString: [(MGWADLResources *) parent base]];
            }
        }
        // (2)
        if (![fullRelativePath hasSuffix: @"/"]) {
            [fullRelativePath appendString: @"/"];
        }
        // (3)
        NSMutableString * substitutedPath = [[self path] mutableCopy];  // Need to substitute the fixed params at this point
        for (MGWADLParam * param in [self params]) {
            if ([[param style] isEqualToString: @"template"] && [param fixed] != nil) {
                NSString * paramSearchToken = [NSString stringWithFormat: @"{%@}", [param name]];

                [substitutedPath replaceOccurrencesOfString: paramSearchToken withString: [param fixed] options: 0 range: NSMakeRange(0, [substitutedPath length]) ];
            }
        }
        // (4)
        if ([substitutedPath hasPrefix: @"/"])  // this path may contain the / at the beginning
            [substitutedPath deleteCharactersInRange:NSMakeRange(0, 1)];

        [fullRelativePath appendString: substitutedPath];
        // (5)
        for (MGWADLParam * param in [self params]) {
            if ([[param style] isEqualToString: @"matrix"] && [param fixed] != nil) {

                if (![[param type] hasSuffix: @"boolean"]) {
                    [fullRelativePath appendFormat: @";%@=%@", [param name], [param fixed]];
                } else {
                    if ([[param fixed] isEqualToString: @"true"]) {
                        [fullRelativePath appendFormat: @";%@", [param name]];
                    }
                }
            }
        }
        return fullRelativePath;
    }

@end