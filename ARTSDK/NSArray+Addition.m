//
//  NSArray+Addition.m
//  Pods
//
//  Created by Anoop's Mac Mini on 24/04/14.
//
//

#import "NSArray+Addition.h"

@implementation NSArray (Addition)

+ (instancetype)arrayWithValidObject:(id)anObject {
 
    if (anObject != nil && ![anObject isKindOfClass:[[NSNull null] class]]) {
        return [self arrayWithObject:anObject];
    }
    else
        return nil;
}

- (id)objectAtValidIndex:(NSInteger)index {
    
    if ([self count] > index && index >= 0) {
        return [self objectAtIndex:(NSUInteger)index];
    }
    return nil;
    
}
@end
