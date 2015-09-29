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

- (BOOL)setValidObject:(id)anObject forValidKey:(id)aKey {
    
    if(anObject!=[NSNull null] && ![anObject isKindOfClass:[NSNull class]] && aKey !=[NSNull null] && ![aKey isKindOfClass:[NSNull class]]) //Change nil to Null class for avoid leaks MWA-786
    {
        [self setObject:anObject forKey:aKey];
        return YES;
    }
    else
        return NO;
    
}

@end
