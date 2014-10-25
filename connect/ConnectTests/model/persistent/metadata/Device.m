//
//  Device.m
//  CloudScope
//
//  Created by Tony Stone on 5/1/12.
//  Copyright (c) 2012 Mobile Grid, Inc. All rights reserved.
//

#import "Device.h"
#import "NSData+AES256.h"
#import "ProviderUserAccount.h"

@implementation Device

@dynamic encryptedMgdid;
@dynamic deviceType;

@synthesize installedVersion;

- (NSString *) mgdid {
    NSData * encryptedMgdid = self.encryptedMgdid;
    if (encryptedMgdid) {
        return [[NSString alloc] initWithData: [encryptedMgdid AES256DecryptWithKey: AES256_KEY] encoding: NSUTF8StringEncoding];
    }
    return nil;
}

- (void) setMgdid:(NSString *) mgdid {
    [self setEncryptedMgdid: [[mgdid dataUsingEncoding: NSUTF8StringEncoding] AES256EncryptWithKey: AES256_KEY]];
}

@end
