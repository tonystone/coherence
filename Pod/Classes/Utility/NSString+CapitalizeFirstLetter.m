//
// Created by Tony Stone on 6/23/15.
//

#import "NSString+CapitalizeFirstLetter.h"


@implementation NSString (CapitalizeFirstLetter)


    - (NSString *)stringWithCapitalizedFirstLetter {
        if (self.length > 0) {
            return [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] capitalizedString]];
        }
        return nil;
    }

@end