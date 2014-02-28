//
//  NSDictionary+Additions.m
//  ArtAPI
//
//  Created by Doug Diego on 3/13/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)

- (id)objectForKeyNotNull:(NSString *)key {
    id object = [self objectForKey:key];
    if ((NSNull *) object == [NSNull null] || (__bridge CFNullRef) object == kCFNull)
        return nil;
    
    return object;
}

@end
