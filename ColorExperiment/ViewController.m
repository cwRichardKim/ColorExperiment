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
@property (nonatomic) UIScrollView* scrollView;
@property (nonatomic) NSInteger currentPageIndex;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.viewControllerCache = [[NSMutableArray alloc] init];
  self.currentPageIndex = 0;

  self.colorArray = @[[UIColor colorWithRed:0.75 green:0.94 blue:0.45 alpha:1], [UIColor colorWithRed:0.03 green:0.79 blue:0.97 alpha:1], [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1], [UIColor colorWithRed:0.94 green:0.36 blue:0.28 alpha:1], [UIColor colorWithRed:0.21 green:0.25 blue:0.31 alpha:1]];

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

- (ContentViewController*)viewControllerAtIndex:(NSUInteger)index {
  if ([self.viewControllerCache count] > index) {
    return [self.viewControllerCache objectAtIndex:index];
  }

  ContentViewController* contentController = [[ContentViewController alloc] init];
  contentController.index = index;
  [contentController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
  [self.viewControllerCache setObject:contentController atIndexedSubscript:index];
  return contentController;
}

#pragma mark - UIPageViewController Delegate

- (void)updatePageIndex {
  self.currentPageIndex = [self.viewControllerCache indexOfObject: [self.pageViewController.viewControllers lastObject]];
}

- (void)pageViewController:(UIPageViewController*)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray*)previousViewControllers transitionCompleted:(BOOL)completed {
  if (completed) {
    [self updatePageIndex];
  }
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
  CGFloat xOffset = scrollView.contentOffset.x;
  CGFloat viewWidth = self.view.frame.size.width;

  CGFloat ratio = (xOffset - viewWidth) / viewWidth;
  NSLog(@"ratio: %f", ratio);
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

  self.pageViewController.view.backgroundColor = color;
}

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
