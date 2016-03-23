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
#import "CDSong.h"

@interface TutorialViewController () <UIPageViewControllerDataSource> {
    __weak IBOutlet UIPageControl *_pageControl;
    NSArray *_contentImages;
    UIPageViewController *_pageViewController;
}
@end

@implementation TutorialViewController

#pragma mark -
#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self createPageViewController];
    
    [self initData];
}

- (void)viewDidAppear:(BOOL)animated; {
    [super viewDidAppear:NO];
}

- (void) createPageViewController {
    _contentImages = @[@"Tutorial-1.png",
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
    if([_contentImages count]) {
        NSArray *startingViewControllers = @[[self itemControllerForIndex: 0]];
        [pageController setViewControllers: startingViewControllers
                                 direction: UIPageViewControllerNavigationDirectionForward
                                  animated: NO
                                completion: nil];
    }
    _pageViewController = pageController;
    [[_pageViewController view] setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [[self view] bounds].size.height + 37)];
    
    [self addChildViewController: _pageViewController];
    [self.view addSubview: _pageViewController.view];
    [_pageViewController didMoveToParentViewController: self];
    [self.view bringSubviewToFront:_pageControl];
}

- (void)initData {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * filePath =[[NSBundle mainBundle] pathForResource:@"app-data" ofType:@"json"];
        
        NSError * error;
        NSString* fileContents =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        NSDictionary *itemDict = (NSDictionary *)[NSJSONSerialization
                                                  JSONObjectWithData:[fileContents dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:0 error:NULL];
        NSArray *chordList = itemDict[@"chords"];
        NSArray *titleList = itemDict[@"titles"];
        
        for (int i = 0; i < titleList.count; i++) {
            NSDictionary *titleDict = titleList[i];
            NSDictionary *chordDict = chordList[i];
            NSString *objectID = titleDict[@"objectId"];
            NSString *title = titleDict[@"title"];
            NSString *chord = chordDict[@"chords"];
            
            CDSong *song = [CDSong getOrCreateSongWithId:[objectID intValue]];
            song.cdTitle = title;
            song.cdIsFavorite = [NSNumber numberWithBool:NO];
            song.cdChord = chord;
            [CDSong saveContext];
        }
//    });
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    PageItemViewController *itemController = (PageItemViewController *) viewController;
    _pageControl.currentPage = itemController.itemIndex;
    if (itemController.itemIndex > 0) {
        return [self itemControllerForIndex: itemController.itemIndex - 1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    PageItemViewController *itemController = (PageItemViewController *) viewController;
    _pageControl.currentPage = itemController.itemIndex;
    if (itemController.itemIndex < [_contentImages count] - 1) {
        return [self itemControllerForIndex: itemController.itemIndex + 1];
    }
    return nil;
}

- (PageItemViewController *)itemControllerForIndex:(NSUInteger)itemIndex {
    if (itemIndex < [_contentImages count]) {
        PageItemViewController *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier: @"ItemController"];
        pageItemController.itemIndex = itemIndex;
        pageItemController.imageName = _contentImages[itemIndex];
        return pageItemController;
    }
    return nil;
}

#pragma mark -
#pragma mark Page Indicator

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    _pageControl.numberOfPages = _contentImages.count;
    return [_contentImages count] ;
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
