//
//  ACSDKAvailability.m
//  ArtAPI
//
//  Created by Doug Diego on 3/8/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//

#import "ACSDKAvailability.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL ACIsPad(void) {
    static NSInteger isPad = -1;
    if (isPad < 0) {
        isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? 1 : 0;
    }
    return isPad > 0;
}