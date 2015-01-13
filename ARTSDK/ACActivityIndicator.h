//
//  ACActivityIndicator.h
//
//
//  Created on 4/24/11.


#import <UIKit/UIKit.h>

typedef enum {
    ACActivityIndicatorTypeLoading,
    ACActivityIndicatorTypeSearching,
} ACActivityIndicatorType;

@interface ACActivityIndicator : UIView {
    UIImageView *animationImage;
    UILabel *label;
}

- (id)initWithActivityIndicatorType:(ACActivityIndicatorType)type;

@end

