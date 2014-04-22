//
//  NSMutableDictionary+SetNull.m
//  artCircles
//
//  Created by Anoop's Mac Mini on 22/04/14.
//  Copyright (c) 2014 Hot Studio. All rights reserved.
//

#import "NSMutableDictionary+SetNull.h"

@implementation NSMutableDictionary (SetNull)

- (BOOL)setObjectNotNull:(id)anObject forKey:(id)aKey
{
    if(anObject!=nil && ![anObject isKindOfClass:[NSNull class]]) {
        [self setObject:anObject forKey:aKey];
        return YES;
    }
    else {
        /*! Null is allowed but it is useless for dev purpose
        [self setObject:[NSNull null] forKey:aKey];
         */
        return NO;
    }
}

@end
