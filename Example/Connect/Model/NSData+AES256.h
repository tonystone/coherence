//
//  NSMutableData+AES256.h
//  CloudScope
//
//  Created by Tony Stone on 5/24/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern char * aes256Key1;
extern char * aes256Key2;
extern char * aes256Key3;
extern char * aes256Key4;
extern char * aes256Key5;
extern char * aes256Key6;
extern char * aes256Key7;
extern char * aes256Key8;
extern char * aes256Key9;
extern char * aes256Key10;
extern char * aes256Key11;
extern char * aes256Key12;
extern char * aes256Key13;
extern char * aes256Key14;
extern char * aes256Key15;
extern char * aes256Key16;

extern char * old_aes256Key1;
extern char * old_aes256Key2;
extern char * old_aes256Key3;
extern char * old_aes256Key4;
extern char * old_aes256Key5;
extern char * old_aes256Key6;
extern char * old_aes256Key7;
extern char * old_aes256Key8;
extern char * old_aes256Key9;

#define AES256_KEY_OLD  ([NSString stringWithFormat: @"%s%s%s%s%s%s%s%s%s",old_aes256Key1, old_aes256Key2, old_aes256Key3, old_aes256Key4, old_aes256Key5, old_aes256Key6, old_aes256Key7, old_aes256Key8, old_aes256Key9])
#define AES256_KEY      ([NSString stringWithFormat: @"%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",aes256Key1, aes256Key2, aes256Key3, aes256Key4, aes256Key5, aes256Key6, aes256Key7, aes256Key8, aes256Key9, aes256Key10, aes256Key11, aes256Key12, aes256Key13, aes256Key14, aes256Key15, aes256Key16])

@interface NSData (AES256) 

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end
