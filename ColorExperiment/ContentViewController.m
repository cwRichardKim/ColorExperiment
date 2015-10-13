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
  self.cardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width * .85, size.height * .8)];
  self.cardView.center = CGPointMake(size.width / 2, size.height / 2);
  self.cardView.backgroundColor = [UIColor whiteColor];
  [self.view addSubview:self.cardView];
  self.cardView.layer.cornerRadius = size.height / 100;
  [self layoutCardElements];
}

- (void)layoutCardElements {
  CGSize cardSize = self.cardView.frame.size;
  UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cardSize.width * .8, cardSize.height * .8)];
  label.text = self.text;
  label.center = CGPointMake(cardSize.width / 2.0, cardSize.height / 2.0);
  label.textAlignment = NSTextAlignmentCenter;
  label.numberOfLines = 0;
  label.lineBreakMode = NSLineBreakByWordWrapping;
  label.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
  label.textColor = [UIColor colorWithWhite:.3 alpha:1];

  if (self.image != NULL) {
    UIImageView* imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.frame = CGRectMake(0, 0, cardSize.width * 0.8, cardSize.height*0.5);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = CGPointMake(cardSize.width / 2.0, cardSize.height / 3.0);
    [self.cardView addSubview:imageView];

    CGRect labelFrame = label.frame;
    labelFrame.size.height = cardSize.height * .45;
    labelFrame.origin.y = cardSize.height *.95 - labelFrame.size.height;
    label.frame = labelFrame;
  }

  [self.cardView addSubview:label];
}

// This method handles all of the card animation.
// It will rotate and move the card depending on the value (ratio) given
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
      [UIView animateWithDuration:0.1 animations:^{
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
