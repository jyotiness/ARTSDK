//
//  NSMutableArray+Addition.h
//  Pods
//
//  Created by Anoop's Mac Mini on 24/04/14.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Addition)

- (void)addValidObject:(id)anObject;
- (void)insertValidObject:(id)anObject atValidIndex:(NSInteger)index;
- (void)removeObjectAtValidIndex:(NSInteger)index;
- (void)replaceObjectAtValidIndex:(NSInteger)index withValidObject:(id)anObject;

@end
