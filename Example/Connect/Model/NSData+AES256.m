//
//  NSMutableData+AES256.m
//  CloudScope
//
//  Created by Tony Stone on 5/24/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import "NSData+AES256.h"
#import <CommonCrypto/CommonCryptor.h>

//  @"23kop467move*#add+128mov+67op+56"
//  @"24df94H4low387l&%@(lksd96723324s"

char * dummy1      = "10";
char * dummy2      = "lk";
char * aes256Key13 = "67";
char * aes256Key8  = "l&";
char * dummy3      = "#E";
char * aes256Key5  = "lo";
char * dummy4      = "FE";
char * aes256Key7  = "87";
char * aes256Key4  = "H4";
char * aes256Key9  = "%@";
char * dummy5      = "4F";
char * dummy6      = "3D";
char * aes256Key3  = "94";
char * dummy7      = "D4";
char * dummy8      = "GG";
char * aes256Key2  = "df";
char * aes256Key6  = "w3";
char * dummy9      = "Df";
char * aes256Key12 = "d9";
char * aes256Key11 = "ks";
char * aes256Key16 = "4s";
char * dummy10     = "Lv";
char * dummy11     = "61";
char * aes256Key1  = "24";
char * aes256Key15 = "32";
char * dummy12     = "sd";
char * dummy13     = "r#";
char * dummy14     = "&G";
char * aes256Key14 = "23";
char * aes256Key10 = "(l";
char * dummy15     = "00";
char * dummy16     = "@@";


char * old_aes256Key4 = "move";
char * old_aes256Key3 = "467";
char * old_aes256Key5 = "*#add";
char * old_aes256Key9 = "op+56";
char * old_aes256Key1 = "23";
char * old_aes256Key7 = "mov";
char * old_aes256Key6 = "+128";
char * old_aes256Key2 = "kop";
char * old_aes256Key8 = "+67";


@implementation NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
    
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

@end

