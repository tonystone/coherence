//
//  User+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 10/8/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "ProviderUser+Extensions.h"
#import "NSData+AES256.h"
#import "ProviderUserAccount.h"

@implementation ProviderUser (Extensions)

- (NSString *) clearTextPassword {
    NSData * encryptedPassword = self.encryptedPassword;
    if (encryptedPassword) {
        return [[NSString alloc] initWithData: [encryptedPassword AES256DecryptWithKey: AES256_KEY] encoding: NSUTF8StringEncoding];
    }
    return nil;
}

- (void) setClearTextPassword:(NSString *)clearTextPassword {
    [self setEncryptedPassword: [[clearTextPassword dataUsingEncoding: NSUTF8StringEncoding] AES256EncryptWithKey: AES256_KEY]];    
}

- (NSArray *) accounts {
    return [self valueForKey: @"fetchAccounts"];
}

- (ProviderUserAccount *) selectedAccount {
    return [[self valueForKey: @"fetchSelectedAccount"] lastObject];
}

@end
