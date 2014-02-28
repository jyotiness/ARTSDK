//
//  ACActivityIndicator.m
//  Art
//


#import "ACActivityIndicator.h"
#import "UIColor+Additions.h"

@implementation ACActivityIndicator

- (NSArray *)animationImagesForSearching {
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (int c = 0; c < 26; c++) {
        NSString *name = [NSString stringWithFormat:@"anim_searching00%02d", c];
        UIImage *image = [UIImage imageNamed:name];
        if (image) [a addObject:image];
    }
    return a;
}

- (NSArray *)animationImagesForLoading {
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (int c = 0; c < 41; c++) {
        NSString *name = [NSString stringWithFormat:@"anim_loading00%02d", c];
        UIImage *image = [UIImage imageNamed:name];
        if (image) [a addObject:image];
    }
    return a;
}

- (id)initWithActivityIndicatorType:(ACActivityIndicatorType)type {
    if (type == ACActivityIndicatorTypeSearching) {
        self = [super initWithFrame:CGRectMake(0, 0, 120, 33)];
    }
    else {
        self = [super initWithFrame:CGRectMake(0, 0, 58, 58)];
    }
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeCenter;
        if (type == ACActivityIndicatorTypeSearching) {
            animationImage = [[UIImageView alloc] initWithFrame:self.frame];
            animationImage.image = [UIImage imageNamed:@"anim_searching0001"];
            animationImage.animationImages = [self animationImagesForSearching];
        }
        else {
            animationImage = [[UIImageView alloc] initWithFrame:self.frame];
            animationImage.image = [UIImage imageNamed:@"anim_loading0001"];
            animationImage.animationImages = [self animationImagesForLoading];
        }

        animationImage.backgroundColor = [UIColor clearColor];
        animationImage.animationDuration = 1.3;
        [animationImage startAnimating];

        if (type == ACActivityIndicatorTypeSearching) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, 120, (84 / 2) - (51 / 2))];
            label.text = NSLocalizedString(@"Searching", nil);
        } else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 58, 60, (84 / 2) - (51 / 2))];
            label.text = NSLocalizedString(@"Loading", nil);
        }

        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"AvenirNextLTPro-Regular" size:12.0f];
        label.backgroundColor = [UIColor clearColor];

        label.textColor = [UIColor artDotComDarkGrayTextColor_iPad];
        [self addSubview:animationImage];
        [self addSubview:label];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithActivityIndicatorType:ACActivityIndicatorTypeLoading];
}


@end
