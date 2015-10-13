//
//  ContentViewController.h
//  ColorExperiment
//
//  Created by Richard Kim on 10/12/15.
//  Copyright © 2015 cwRichardKim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentViewController : UIViewController

@property NSUInteger index;
@property (nonatomic, readonly) UIImage* image;
@property (nonatomic, readonly) NSString* text;

- (instancetype)initWithImage:(UIImage*)image andText:(NSString*)text;
- (void)transformNodeWithScrollViewRatio:(CGFloat)ratio;

@end
