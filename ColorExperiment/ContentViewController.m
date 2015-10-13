//
//  ContentViewController.m
//  ColorExperiment
//
//  Created by Richard Kim on 10/12/15.
//  Copyright © 2015 cwRichardKim. All rights reserved.
//

#import "ContentViewController.h"

static const CGFloat kContentImageParallaxHorizontalDistance = 200.0;
static const CGFloat kContentScaleResistance = 3;
static const CGFloat kContentScaleMax = .96;
static const CGFloat kContentRotationMax = 1;
static const CGFloat kContentRotationResistance = 300;
static const CGFloat kContentRotationAngle = M_PI/12;

@interface ContentViewController ()

@property (nonatomic) UIView* cardView;

@end

@implementation ContentViewController

- (instancetype)initWithImage:(UIImage*)image andText:(NSString*)text {
    self = [super init];
    if (self) {
      _image = image;
      _text = text;
    }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  CGSize size = self.view.frame.size;
  self.cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width * .8, size.height * .8)];
  self.cardView.center = CGPointMake(size.width / 2, size.height / 2);
  self.cardView.backgroundColor = [UIColor redColor];
  self.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:(float)rand() / RAND_MAX];
  [self.view addSubview:self.cardView];
}

- (void)transformNodeWithScrollViewRatio:(CGFloat)ratio {
  if (self.cardView) {
    CGPoint center = self.view.center;
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat xFromCenter = ratio * viewWidth;

    CGFloat rotationStrength = - MIN(xFromCenter / kContentRotationResistance, kContentRotationMax);
    CGFloat rotationAngle = (CGFloat) (kContentRotationAngle * rotationStrength);
    CGFloat scale = MAX(1 - fabs(rotationStrength) / kContentScaleResistance, kContentScaleMax);
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotationAngle);
    CGAffineTransform scaleTransform = CGAffineTransformScale(rotationTransform, scale, scale);

    if (ratio == 0.0) {
      [UIView animateWithDuration:0.2 animations:^{
        self.cardView.center = CGPointMake(center.x, self.cardView.center.y);
        self.cardView.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0), 1, 1);
      }];
    } else {
      self.cardView.center = CGPointMake(center.x - kContentImageParallaxHorizontalDistance * ratio, self.cardView.center.y);
      self.cardView.transform = scaleTransform;
    }
  }
}

@end
