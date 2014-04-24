//
//  NSMutableArray+Addition.m
//  Pods
//
//  Created by Anoop's Mac Mini on 24/04/14.
//
//

#import "NSMutableArray+Addition.h"

@implementation NSMutableArray (Addition)

- (void)addValidObject:(id)anObject {
    
    if (anObject != nil && ![anObject isKindOfClass:[[NSNull null] class]]) {
        [self addObject:anObject];
    }
    
}

- (void)insertValidObject:(id)anObject atValidIndex:(NSInteger)index {
    
    if ([self count] > index && index >= 0 && anObject != nil && ![anObject isKindOfClass:[[NSNull null] class]]) {
        [self insertObject:anObject atIndex:index];
    }
    
}

- (void)removeObjectAtValidIndex:(NSInteger)index {
    
    if ([self count] > index && index >= 0) {
       [self removeObjectAtIndex:index];
    }
    
}

- (void)replaceObjectAtValidIndex:(NSInteger)index withValidObject:(id)anObject {
    
    if ([self count] > index && index >= 0 && anObject != nil && ![anObject isKindOfClass:[[NSNull null] class]]) {
        [self replaceObjectAtIndex:index withObject:anObject];
    }
    
}


@end
