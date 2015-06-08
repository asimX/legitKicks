//
//  SLKeyChain.h
//  Snakke Litt
//
//  Created by SUNIL on 27/05/14.
//  Copyright (c) 2014 weetech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKKeyChain : NSObject

+(void)setObject:(id)obj forKey:(NSString*)key;
+(id)objectForKey:(NSString *)key;
+(void)removeObjectForKey:(NSString *)key;
+(BOOL)boolStringForKey:(NSString *)key;

@end
