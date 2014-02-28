//
//  NSDate+Additions.h
//  ArtAPI
//
//  Created by Doug Diego on 10/15/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

+ (NSDate *)stringToDate:(NSString *)string;

+ (NSString *)dateToString:(NSDate *)date;

@end
