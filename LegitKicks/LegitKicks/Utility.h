//
//  Utility.h
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 03/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define RGB(r, g, b)        [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define LOADING_TAG 10000

@interface Utility : NSObject

+(UIColor *)colorFromHex:(NSString *)hex;
+(UIColor *)colorFromHex:(NSString *)hex alpha:(CGFloat)alpha;

+(UIActivityIndicatorView *)loadingViewForView:(UIView *)view;

+(void)displayAlertWithTitle:(NSString *)title andMessage:(NSString *)message;
+(void)displayHttpFailureError:(NSError *)error;

+(NSString *)getLibraryDirectoryPath;
+(NSString *)getDocumentDirectoryPath;

+(BOOL)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath;
+(BOOL)createDirectoryAtLibraryDirectory:(NSString *)directoryName;
+(BOOL)createDirectoryAtDocumentDirectory:(NSString *)directoryName;

+(BOOL)deleteFileFromPath:(NSString *)filePath;
+(BOOL)deleteAllFilesAtDirectory:(NSString *)directoryPath;

+(BOOL)isFileOrDirectoryExistAtPath:(NSString *)path;

+(void)deleteFileNameStartWithText:(NSString *)searchText atDirectory:(NSString *)directory;

@end
