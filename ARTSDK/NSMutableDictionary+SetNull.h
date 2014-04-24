//
//  NSMutableDictionary+SetNull.h
//  artCircles
//
//  Created by Anoop's Mac Mini on 22/04/14.
//  Copyright (c) 2014 Hot Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SetNull)

- (BOOL)setObjectNotNull:(id)anObject forKey:(id)aKey;
- (BOOL)setValidObject:(id)anObject forValidKey:(id)aKey;

@end
