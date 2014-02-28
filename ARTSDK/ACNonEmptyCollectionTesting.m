//
//  ACNonEmptyCollectionTesting.m
//  ArtAPI
//
//  Created by Doug Diego on 4/3/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACNonEmptyCollectionTesting.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL ACIsArrayWithItems(id object) {
    return [object isKindOfClass:[NSArray class]] && [(NSArray*)object count] > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL ACIsSetWithObjects(id object) {
    return [object isKindOfClass:[NSSet class]] && [(NSSet*)object count] > 0;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL ACIsStringWithAnyText(id object) {
    return [object isKindOfClass:[NSString class]] && [(NSString*)object length] > 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL ACIsDictionaryWithObjects(id object) {
	return [object isKindOfClass:[NSDictionary class]] && [(NSDictionary*)object count] > 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL ACIsNumberWithNumber(id object) {
	return [object isKindOfClass:[NSNumber class]] && !([object  isEqual:[NSNull null]]);
}
