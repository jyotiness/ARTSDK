//
//  ARTLogger.h
//  ARTSDKExample
//
//  Created by Doug Diego on 2/26/14.
//  Copyright (c) 2014 Art.com, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TargetConditionals.h>



#define ARTError(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#ifdef DEBUG
#define ARTLog(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define ARTLog(xx, ...)  ((void)0)
#endif // #ifdef DEBUG