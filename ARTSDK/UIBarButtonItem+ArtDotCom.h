//
//  UIBarButtonItem+ArtDotCom.h
//  Art
//
//  Created by Brad Smith on 6/21/11.


#import <Foundation/Foundation.h>


typedef enum {
    ACBarButtonItemStyleAdd = 0,
    ACBarButtonItemStyleAirPlay,
    ACBarButtonItemStyleClose,
    ACBarButtonItemStyleGridView,
    ACBarButtonItemStyleLeftArrow,
    ACBarButtonItemStyleListView,
    ACBarButtonItemStyleRightArrow,
    ACBarButtonItemStyleSearch,

} ACBarButtonItemStyle;


@interface UIBarButtonItem (UIBarButtonItem_ArtDotCom)

+ (UIBarButtonItem *)customButtonWithStyle:(ACBarButtonItemStyle)style target:(id)target action:(SEL)action;

+ (UIBarButtonItem *)customButtonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end
