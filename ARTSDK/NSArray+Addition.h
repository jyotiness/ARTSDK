//
//  NSArray+Addition.h
//  Pods
//
//  Created by Anoop's Mac Mini on 24/04/14.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (Addition)

+ (instancetype)arrayWithValidObject:(id)anObject;
- (id)objectAtValidIndex:(NSInteger)index;

@end
