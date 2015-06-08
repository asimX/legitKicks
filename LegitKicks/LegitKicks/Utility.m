//
//  Utility.m
//  LegitKicks
//
//  Created by Sunil Zalavadiya on 03/11/14.
//  Copyright (c) 2014 Sunil Zalavadiya. All rights reserved.
//

#import "Utility.h"

@implementation Utility


+ (UIColor *)colorwithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
{
    //-----------------------------------------
    // Convert hex string to an integer
    //-----------------------------------------
    unsigned int hexint = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet
                                       characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];
    
    //-----------------------------------------
    // Create color object, specifying alpha
    //-----------------------------------------
    UIColor *color =
    [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                    green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                     blue:((CGFloat) (hexint & 0xFF))/255
                    alpha:alpha];
    
    return color;
}


+(UIColor *)colorFromHex:(NSString *)hex
{
    return [[self class] colorwithHexString:hex alpha:1.0];
}

+(UIColor *)colorFromHex:(NSString *)hex alpha:(CGFloat)alpha
{
    return [[self class] colorwithHexString:hex alpha:alpha];
}


+(UIActivityIndicatorView *)loadingViewForView:(UIView *)view
{
	UIActivityIndicatorView *lv = (UIActivityIndicatorView *)[view viewWithTag:LOADING_TAG];
	if (lv == nil)
    {
		lv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        lv.color = [UIColor colorWithRed:26.0/255.0 green:85.0/255.0 blue:68.0/255.0 alpha:1.0];
		[lv setHidesWhenStopped:TRUE];
		CGRect frame = lv.frame;
		frame.origin.x = round((view.frame.size.width - frame.size.width) / 2.);
		frame.origin.y = round((view.frame.size.height - frame.size.height) / 2.);
		lv.frame = frame;
		lv.tag = LOADING_TAG;
		[view addSubview:lv];
	}
	return lv;
}


#pragma mark Display alert
+(void)displayAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
    [alert show];
}


#pragma mark Display HTTP failure error
+(void)displayHttpFailureError:(NSError *)error
{
    NSLog(@"failure error = %@",error);
    
    switch ([error code])
    {
        case NSURLErrorUnknown:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"connection_fail", nil)];
            break;
        }
        case NSURLErrorCancelled:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorBadURL:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"connection_fail", nil)];
            break;
        }
        case NSURLErrorTimedOut:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
            /*case NSURLErrorUnsupportedURL:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }*/
        case NSURLErrorCannotFindHost:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"can_not_find_host", nil)];
            break;
        }
        case NSURLErrorCannotConnectToHost:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"can_not_connect_to_host", nil)];
            break;
        }
        case NSURLErrorDataLengthExceedsMaximum:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"data_length_exceeds_maximum", nil)];
            break;
        }
        case NSURLErrorNetworkConnectionLost:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"network_lost", nil)];
            break;
        }
            /*case NSURLErrorDNSLookupFailed:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }
             case NSURLErrorHTTPTooManyRedirects:
             {
             //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
             break;
             }*/
        case NSURLErrorResourceUnavailable:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"resource_not_found", nil)];
            break;
        }
        case NSURLErrorNotConnectedToInternet:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
            break;
        }
        /*case NSURLErrorRedirectToNonExistentLocation:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }*/
        case NSURLErrorBadServerResponse:
        {
            [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internal_server_error", nil)];
            break;
        }
        /*case NSURLErrorUserCancelledAuthentication:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorUserAuthenticationRequired:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorZeroByteResource:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotDecodeRawData:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotDecodeContentData:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotParseResponse:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorInternationalRoamingOff:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCallIsActive:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorDataNotAllowed:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorRequestBodyStreamExhausted:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorFileDoesNotExist:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorFileIsDirectory:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorNoPermissionsToReadFile:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorSecureConnectionFailed:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorServerCertificateHasBadDate:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorServerCertificateUntrusted:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorServerCertificateHasUnknownRoot:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorServerCertificateNotYetValid:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorClientCertificateRejected:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorClientCertificateRequired:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotLoadFromNetwork:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotCreateFile:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotOpenFile:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotCloseFile:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotWriteToFile:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotRemoveFile:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorCannotMoveFile:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorDownloadDecodingFailedMidStream:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }
        case NSURLErrorDownloadDecodingFailedToComplete:
        {
            //[[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            break;
        }*/
            
        default:
        {
            
            if ([[error description] rangeOfString:@"The request timed out."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"request_time_out", nil)];
            }
            else if ([[error description] rangeOfString:@"The server can not find the requested page"].location != NSNotFound || [[error description] rangeOfString:@"A server with the specified hostname could not be found."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_error", nil)];
            }
            else if([[error description] rangeOfString:@"The network connection was lost."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"network_lost", nil)];
            }
            else if([[error description] rangeOfString:@"The Internet connection appears to be offline."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"internet_appears_offline", nil)];
            }
            else if ([[error description] rangeOfString:@"</html>"].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_exception_error", nil)];
            }
            else if ([[error description] rangeOfString:@"JSON text did not start with array or object and option to allow fragments not set."].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_exception_error", nil)];
            }
            else if ([[error description] rangeOfString:@"Request failed: not found (404)"].location != NSNotFound)
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"server_exception_error", nil)];
            }
            else
            {
                [[self class] displayAlertWithTitle:NSLocalizedString(@"error", nil) andMessage:NSLocalizedString(@"connection_fail", nil)];
            }
            
            break;
        }
    }
}


+(NSString *)getLibraryDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    
    return paths[0];
}

+(NSString *)getDocumentDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return paths[0];
}

+(BOOL)createDirectory:(NSString *)directoryName atFilePath:(NSString *)filePath
{
    NSString *filePathAndDirectory = [filePath stringByAppendingPathComponent:directoryName];
    
    if([[self class] isFileOrDirectoryExistAtPath:filePathAndDirectory])
        return YES;
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:NO attributes:nil error:&error])
    {
        NSLog(@"Create directory error: %@", error);
        return NO;
    }
    else
    {
        return YES;
    }
}


+(BOOL)createDirectoryAtLibraryDirectory:(NSString *)directoryName
{
    NSString *filePathAndDirectory = [[[self class] getLibraryDirectoryPath] stringByAppendingPathComponent:directoryName];
    
    
    if([[self class] isFileOrDirectoryExistAtPath:filePathAndDirectory])
        return YES;
    
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:NO attributes:nil error:&error])
    {
        NSLog(@"Create directory error: %@", error);
        return NO;
    }
    else
    {
        return YES;
    }
}

+(BOOL)createDirectoryAtDocumentDirectory:(NSString *)directoryName
{
    NSString *filePathAndDirectory = [[[self class] getLibraryDirectoryPath] stringByAppendingPathComponent:directoryName];
    
    if([[self class] isFileOrDirectoryExistAtPath:filePathAndDirectory])
        return YES;
    
    
    NSError *error;
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:filePathAndDirectory withIntermediateDirectories:NO attributes:nil error:&error])
    {
        NSLog(@"Create directory error: %@", error);
        return NO;
    }
    else
    {
        return YES;
    }
}

+(BOOL)deleteFileFromPath:(NSString *)filePath
{
    NSLog(@"Path: %@", filePath);
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL deleted = [fileManager removeItemAtPath:filePath error:&error];
    
    if (deleted != YES || error != nil)
    {
        NSLog(@"Delete directory error: %@", error);
        
        return NO;
    }
    else
    {
        return YES;
    }
}

+(BOOL)deleteAllFilesAtDirectory:(NSString *)directoryPath
{
    NSLog(@"Path: %@", directoryPath);
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL deleted = [fileManager removeItemAtPath:directoryPath error:&error];
    
    if (deleted != YES || error != nil)
    {
         NSLog(@"Delete directory error: %@", error);
        
        return NO;
    }
    else
    {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:&error];
        
        return YES;
    }
}

+(BOOL)isFileOrDirectoryExistAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
    {
        return YES;
    }
    
    return NO;
}

+(void)deleteFileNameStartWithText:(NSString *)searchText atDirectory:(NSString *)directory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    
    for (NSString *fileString in dirContents)
    {
        if ([[fileString lowercaseString] hasPrefix:[searchText lowercaseString]])
        {
            NSLog(@"delete file = %@",fileString);
            [self deleteFileFromPath:[directory stringByAppendingPathComponent:fileString]];
        }
    }
}

@end
