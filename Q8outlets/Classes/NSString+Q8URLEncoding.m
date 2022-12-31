//
//  NSString+Q8URLEncoding.m
//  Q8outlets
//
//  Created by ProCreationsMac on 07.05.2018.
//  Copyright © 2018 Lesya Verbina. All rights reserved.
//

#import "NSString+Q8URLEncoding.h"

@implementation NSString (Q8URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
																				 (CFStringRef)self,
																				 NULL,
																				 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
																				 CFStringConvertNSStringEncodingToEncoding(encoding)));
}

@end
