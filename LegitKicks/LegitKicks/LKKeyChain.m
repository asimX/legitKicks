//
//  SLKeyChain.m
//  Snakke Litt
//
//  Created by SUNIL on 27/05/14.
//  Copyright (c) 2014 weetech. All rights reserved.
//

#import "LKKeyChain.h"
#import "CocoaSecurity.h"
#import <CommonCrypto/CommonDigest.h>

#define kStoredObjectKey    @"storeLegitKicksObject"
#define APP_KEY_STR         (@"Legit" @"Kicks")
#define kKeychainService    @"com.app.legitkicks"

@implementation LKKeyChain

+(NSString *)MD5StringFromString:(NSString *)str
{
    const char *cstr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(NSMutableDictionary *)getKeychainQuery:(NSString *)key
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            kKeychainService, (__bridge id)kSecAttrService,
            key, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly, (__bridge id)kSecAttrAccessible,
            nil];
}

+(void)setObject:(id)obj forKey:(NSString*)key
{
    
    NSString *secValue = [self MD5StringFromString:[APP_KEY_STR  stringByAppendingString:key]];
    secValue = [self MD5StringFromString:[key stringByAppendingString:secValue]];
    
    // Create data object from dictionary
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:obj forKey:kStoredObjectKey];
    [archiver finishEncoding];
    
    // Generate key and IV
    CocoaSecurityResult *keyData = [CocoaSecurity sha384:secValue];
    NSData *aesKey = [keyData.data subdataWithRange:NSMakeRange(0, 32)];
    NSData *aesIv = [keyData.data subdataWithRange:NSMakeRange(32, 16)];
    
    // Encrypt data
    CocoaSecurityResult *result = [CocoaSecurity aesEncryptWithData:data key:aesKey iv:aesIv];
    
    
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    // delete any previous value with this key
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:result.data] forKey:(__bridge id)kSecValueData];
    
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+(id)objectForKey:(NSString *)key
{
    id value = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    CFDataRef keyData = NULL;
    
    [keychainQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            value = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
            
            if(value == nil) {
                
                if (keyData) {
                    CFRelease(keyData);
                }
                
                return nil;
            }
            
            NSString *secValue = [self MD5StringFromString:[APP_KEY_STR  stringByAppendingString:key]];
            secValue = [self MD5StringFromString:[key stringByAppendingString:secValue]];
            
            // Generate key and IV
            CocoaSecurityResult *keyData1 = [CocoaSecurity sha384:secValue];
            NSData *aesKey = [keyData1.data subdataWithRange:NSMakeRange(0, 32)];
            NSData *aesIv = [keyData1.data subdataWithRange:NSMakeRange(32, 16)];
            
            // Decrypt data
            CocoaSecurityResult *result = [CocoaSecurity aesDecryptWithData:value key:aesKey iv:aesIv];
            
            // Turn data into object and return
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:result.data];
            id object = [unarchiver decodeObjectForKey:kStoredObjectKey];
            [unarchiver finishDecoding];
            
            if (keyData) {
                CFRelease(keyData);
            }
            
            return object;
            
        }
        @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", key, e);
            return nil;
        }
        @finally {}
    }
    
    if (keyData) {
        CFRelease(keyData);
    }
    
    return value;
}

+(void)removeObjectForKey:(NSString *)key
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}


+(BOOL)boolStringForKey:(NSString *)key
{
    id value = nil;
    
    value = [LKKeyChain objectForKey:key];
    
    if([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]])
    {
        if(value==nil)
            return NO;
    }
    else if([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]])
    {
        if(value==nil)
            return NO;
    }
    else
    {
        if(value!=nil)
        {
            NSString * valueStr = nil;
            valueStr = [NSString stringWithFormat:@"%@",value];
            if ([valueStr length]==0)
            {
                return NO;
            }
        }
        else
        {
            return NO;
        }
    }
    
    return YES;
}

@end
