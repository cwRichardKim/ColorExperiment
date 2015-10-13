//
//  ViewController.m
//  ColorExperiment
//
//  Created by Richard Kim on 10/12/15.
//  Copyright © 2015 cwRichardKim. All rights reserved.
//

#import "ContentViewController.h"
#import "ViewController.h"

@interface ViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@property (nonatomic) UIPageViewController* pageViewController;
@property (nonatomic) NSMutableArray* viewControllerCache;
@property (nonatomic) NSArray* colorArray;
@property (nonatomic) NSArray* textArray;
@property (nonatomic) NSArray* imageArray;
@property (nonatomic) UIScrollView* scrollView;
@property (nonatomic) NSInteger currentPageIndex;

@end

@implementation ViewController

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// DISCLAIMER:
// this is 100% my own code, but I've made similar
// things in the past, so I used past projects
// as reference.  This was still a new idea written
// from scratch for this assignment, but I wanted
// to make sure that was clear.  Thanks!
//

- (void)viewDidLoad {
  [super viewDidLoad];

  self.viewControllerCache = [[NSMutableArray alloc] init];
  self.currentPageIndex = 0;

  // feel free to change these colors!
  UIColor* color1 = [UIColor colorWithRed:0.75 green:0.94 blue:0.45 alpha:1];
  UIColor* color2 = [UIColor colorWithRed:0.03 green:0.79 blue:0.97 alpha:1];
  UIColor* color3 = [UIColor colorWithRed:0.94 green:0.36 blue:0.28 alpha:1];
  UIColor* color4 = [UIColor colorWithRed:1 green:0.89 blue:0.23 alpha:1];
  UIColor* color5 = color1;
  UIColor* color6 = color2;
  UIColor* color7 = [UIColor colorWithRed:0.92 green:0.92 blue:0.93 alpha:1];

  self.colorArray = @[color1, color2, color3, color4, color5, color6, color7];

  // Or change these strings! (though be gentle, I haven't spent enough time covering edge cases)
  NSString* string1 = @"Hey There!\nThis is my submission for the Squarespace internship application.\n\nGo ahead and swipe from right to left!\n\n<----o";
  NSString* string2 = @"This is an onboarding concept I had a few months ago, where each card would contain a little snippet of information.\n\nThis card is used to demonstrate how I built it to dynamically place the text according to whether or not there is an image.\n\nIt's currently quite simple, and the next step would be to adapt to the size of the image";
  NSString* string3 = @"While I have your attention, let me tell you a little about me!\n\n\U0001F601";
  NSString* string4 = @"I'm a developer / designer who prides himself in his work ethic, attention to detail, and ability to build relationships.\n\n(also this is me with my baby brother. We have fun)";
  NSString* string5 = @"In freshman year I started and ran a company for 17 months.\n\nSince then, my projects have been on all sorts of websites (for all sorts of reasons)";
  NSString* string6 = @"I've also developed a significant amount of open-sourced code.\n\nIn February of 2015, Github ranked me as the 7th hottest Objective-C developer of the month, in front of Twitter's development team (bit.do/gh7)";
  NSString* string7 = @"Thanks so much for taking the time to check out what I've put together!\n\nThroughout my career, I've spent over 4,000 hours writing mobile code, and I hope this demonstrates some of my experience.\n\nTo see more of my stuff, feel free to check out bit.ly/RKgithub";

  self.textArray = @[string1, string2, string3, string4, string5, string6, string7];

  UIImage* image1 = [UIImage imageNamed:@"squarespaceLogo"];
  UIImage* image2 = NULL;
  UIImage* image3 = [UIImage imageNamed:@"me1"];
  UIImage* image4 = [UIImage imageNamed:@"me2"];
  UIImage* image5 = [UIImage imageNamed:@"logos"];
  UIImage* image6 = [UIImage imageNamed:@"github"];
  UIImage* image7 = [UIImage imageNamed:@"cheer"];

  self.imageArray = @[image1 ?: [NSNull null], image2?: [NSNull null], image3?: [NSNull null], image4?: [NSNull null], image5?: [NSNull null], image6?: [NSNull null], image7?: [NSNull null]];

  NSAssert(self.colorArray.count <= self.textArray.count && self.colorArray.count <= self.imageArray.count, @"The color array is used to determine the number of cards we create.  This will cause index out of bounds");

  [self loadPageViewController];
  [self setScrollViewDelegate];
}

- (void)loadPageViewController {
  self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
  self.pageViewController.dataSource = self;
  self.pageViewController.delegate = self;
  self.pageViewController.view.frame = self.view.bounds;
  self.pageViewController.view.backgroundColor = [self.colorArray objectAtIndex:0];

  [self addChildViewController:self.pageViewController];
  [self.view addSubview:self.pageViewController.view];
  [self.pageViewController didMoveToParentViewController:self];

  UIViewController* initialViewController = [self viewControllerAtIndex:0];

  // fixes the crash when the user grabs the first page and pulls it back by clearing the animation cache
  __weak typeof(self) weakSelf = self;
  [self.pageViewController setViewControllers:@[initialViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
    if (finished) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.pageViewController setViewControllers:@[initialViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
      });
    }
  }];
}

// UIPageViewController doesn't want to expose UIScrollView,
// So I found a brute-force way of finding it and forcing it out
- (void)setScrollViewDelegate {
  for (UIView* view in self.pageViewController.view.subviews){
    if([view isKindOfClass:[UIScrollView class]]) {
      self.scrollView = (UIScrollView*)view;
      self.scrollView.delegate = self;
    }
  }
}

- (void)dealloc {
  self.pageViewController.delegate = nil;
  self.scrollView.delegate = nil;
}

#pragma mark - UIPageViewController DataSource

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController viewControllerBeforeViewController:(UIViewController*)viewController {
  NSUInteger index = [(ContentViewController*)viewController index];
  if (index <= 0) {
    return nil;
  }

  index--;

  return [self viewControllerAtIndex:index];
}

- (UIViewController*)pageViewController:(UIPageViewController*)pageViewController viewControllerAfterViewController:(UIViewController*)viewController {
  NSUInteger index = [(ContentViewController*)viewController index];

  if (index == self.colorArray.count - 1) {
    return nil;
  }

  index++;

  return [self viewControllerAtIndex:index];
}

// Request for a content page
// If we've loaded the page before (i.e. it's in the cache), pull from the cache
// Else load the page and put it in the cache
- (ContentViewController*)viewControllerAtIndex:(NSUInteger)index {
  if ([self.viewControllerCache count] > index) {
    return [self.viewControllerCache objectAtIndex:index];
  }

  UIImage* image = self.imageArray[index] != [NSNull null] ? self.imageArray[index] : NULL;

  ContentViewController* contentController = [[ContentViewController alloc] initWithImage:image andText:self.textArray[index]];
  contentController.index = index;
  [contentController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
  [self.viewControllerCache setObject:contentController atIndexedSubscript:index];
  return contentController;
}

#pragma mark - UIPageViewController Delegate

// These methods are required because UIPageViewController is not meant to expose the UIScrollView, so there's some internal logic that conflicts with my logic.

- (void)updatePageIndex {
  self.currentPageIndex = [self.viewControllerCache indexOfObject: [self.pageViewController.viewControllers lastObject]];
}

- (void)pageViewController:(UIPageViewController*)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray*)previousViewControllers transitionCompleted:(BOOL)completed {
  if (completed) {
    [self updatePageIndex];
  }
}

#pragma mark UIScrollView Delegate

// While we are turning the page, this method calculates a ratio between -1 and 1
// for how much we've turned the page so far (0 = no turn, -1 = fully swiped left, 1 = right)
// This number is then passed to the content controller so that it can
// handle card animations
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  CGFloat xOffset = scrollView.contentOffset.x;
  CGFloat viewWidth = self.view.frame.size.width;

  CGFloat ratio = (xOffset - viewWidth) / viewWidth;
  NSInteger index = self.currentPageIndex;
  NSInteger viewControllerCount = self.viewControllerCache.count;

  UIColor* color = [self.colorArray objectAtIndex:index];

  NSInteger nextIndex;
  CGFloat nextRatio;
  if (ratio >= 0.0) {
    nextIndex = MIN (viewControllerCount - 1, index + 1);
    nextRatio = ratio - 1;
    UIColor* nextColor = [self.colorArray objectAtIndex: nextIndex];
    color = [self averageBetweenColor:color andColor:nextColor withRatio:ratio];
  } else {
    nextIndex = MAX (0, index - 1);
    nextRatio = ratio - 1;
    UIColor* nextColor = [self.colorArray objectAtIndex: nextIndex];
    color = [self averageBetweenColor:color andColor:nextColor withRatio:ratio];
  }

  ContentViewController* vc = [self viewControllerAtIndex:index];
  ContentViewController* nextVC = [self viewControllerAtIndex:nextIndex];

  [vc transformNodeWithScrollViewRatio:ratio];
  if (nextIndex > index) {
    [nextVC transformNodeWithScrollViewRatio:ratio - 1];
  } else if (nextIndex != index) {
    [nextVC transformNodeWithScrollViewRatio:1 + ratio];
  }

  self.pageViewController.view.backgroundColor = color;
}

// This method takes two colors and the ratio from the method above and returns
// an appropriately mixed color based on how far the user has turned the page
- (UIColor*)averageBetweenColor:(UIColor*)color1 andColor:(UIColor*)color2 withRatio:(CGFloat)ratio {
  const CGFloat* colorComponents = CGColorGetComponents([color1 CGColor]);
  const CGFloat* nextColorComponents = CGColorGetComponents([color2 CGColor]);

  CGFloat absRatio = ABS(ratio);
  CGFloat redValue = colorComponents[0] * (1 - absRatio) + nextColorComponents[0] * absRatio;
  CGFloat greenValue = colorComponents[1] * (1 - absRatio) + nextColorComponents[1] * absRatio;
  CGFloat blueValue = colorComponents[2] * (1 - absRatio) + nextColorComponents[2] * absRatio;
  CGFloat alphaValue = colorComponents[3] * (1 - absRatio) + nextColorComponents[3] * absRatio;

  return [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:alphaValue];
}

@end
