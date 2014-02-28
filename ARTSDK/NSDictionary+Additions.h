//
//  NSDictionary+Additions.h
//  ArtAPI
//
//  Created by Doug Diego on 3/13/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)
- (id)objectForKeyNotNull:(NSString *)key;
@end
