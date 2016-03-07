//
//  TutorialViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "TutorialViewController.h"
#import "PageItemViewController.h"
#import "MainTabbarController.h"

@interface TutorialViewController () <UIPageViewControllerDataSource> {
    __weak IBOutlet UIPageControl *_pageControl;
}

@property (nonatomic, strong) NSArray *contentImages;
@property (nonatomic, strong) UIPageViewController *_pageViewController;

@end

@implementation TutorialViewController
@synthesize contentImages;

#pragma mark -
#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self createPageViewController];
}

- (void)viewDidAppear:(BOOL)animated; {
    [super viewDidAppear:NO];
}

- (void) createPageViewController {
    contentImages = @[@"Tutorial-1.png",
                      @"Tutorial-2.png",
                      @"Tutorial-3.png",
                      @"Tutorial-4.png",
                      @"Tutorial-5.png",
                      @"Tutorial-6.png",
                      @"Tutorial-7.png",
                      @"Tutorial-8.png",
                      @"Tutorial-9.png"];
    
    UIPageViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier: @"PageController"];
    pageController.dataSource = self;
    
    if([contentImages count]) {
        NSArray *startingViewControllers = @[[self itemControllerForIndex: 0]];
        [pageController setViewControllers: startingViewControllers
                                 direction: UIPageViewControllerNavigationDirectionForward
                                  animated: NO
                                completion: nil];
    }
    
    self._pageViewController = pageController;
    [[self._pageViewController view] setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [[self view] bounds].size.height + 37)];
    
    [self addChildViewController: self._pageViewController];
    [self.view addSubview: self._pageViewController.view];
    [self._pageViewController didMoveToParentViewController: self];
    
    [self.view bringSubviewToFront:_pageControl];
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerBeforeViewController:(UIViewController *) viewController {
    PageItemViewController *itemController = (PageItemViewController *) viewController;
    
    _pageControl.currentPage = itemController.itemIndex;
    
    if (itemController.itemIndex > 0) {
        return [self itemControllerForIndex: itemController.itemIndex - 1];
    }
    return nil;
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerAfterViewController:(UIViewController *) viewController {
    PageItemViewController *itemController = (PageItemViewController *) viewController;
    
    _pageControl.currentPage = itemController.itemIndex;
    
    if (itemController.itemIndex < [contentImages count] - 1) {
        return [self itemControllerForIndex: itemController.itemIndex + 1];
    }
    return nil;
}

- (PageItemViewController *) itemControllerForIndex: (NSUInteger) itemIndex {
    if (itemIndex < [contentImages count]) {
        PageItemViewController *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier: @"ItemController"];
        pageItemController.itemIndex = itemIndex;
        pageItemController.imageName = contentImages[itemIndex];
        return pageItemController;
    }
    
    return nil;
}

#pragma mark -
#pragma mark Page Indicator

- (NSInteger) presentationCountForPageViewController: (UIPageViewController *) pageViewController {
    _pageControl.numberOfPages = contentImages.count;
    
    return [contentImages count] ;
}

- (NSInteger) presentationIndexForPageViewController: (UIPageViewController *) pageViewController {
    return 0;
}

@end
