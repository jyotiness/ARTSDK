//
//  ACNonEmptyCollectionTesting.h
//  ArtAPI
//
//  Created by Doug Diego on 4/3/13.
//  Copyright (c) 2013 Doug Diego. All rights reserved.
//


#import <Foundation/Foundation.h>

#if defined __cplusplus
extern "C" {
#endif

    /**
     * Tests if an object is a non-nil array which is not empty.
     */
    BOOL ACIsArrayWithItems(id object);
    
    /**
     * Tests if an object is a non-nil set which is not empty.
     */
    BOOL ACIsSetWithObjects(id object);
    
    /**
     * Tests if an object is a non-nil string which is not empty.
     */
    BOOL ACIsStringWithAnyText(id object);
    
    BOOL ACIsDictionaryWithObjects(id object) ;
    
    BOOL ACIsNumberWithNumber(id object);
    
#if defined __cplusplus
};
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
/**@}*/// End of Non-Empty Collection Testing /////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////