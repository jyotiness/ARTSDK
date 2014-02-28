//
//  ACSDKAvailability.h
//  ArtAPI
//
//  Created by Doug Diego on 3/8/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __cplusplus
extern "C" {
#endif
    
    /**
     * Checks whether the device the app is currently running on is an iPad or not.
     *
     *      @returns YES if the device is an iPad.
     */
    BOOL ACIsPad(void);

#if __cplusplus
} // extern "C"
#endif