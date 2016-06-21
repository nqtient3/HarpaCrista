//
//  TutorialViewController.m
//  HarpaCrista
//
//  Created by MacAir on 3/5/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "TutorialViewController.h"
#import "PageItemViewController.h"
#import "BaseApi.h"
#import "CDSong.h"

@interface TutorialViewController () <UIPageViewControllerDataSource> {
    __weak IBOutlet UIPageControl *_pageControl;
    NSArray *_contentTitle;
    NSArray *_contentDescription;
    UIPageViewController *_pageViewController;
}
@end

@implementation TutorialViewController

#pragma mark -
#pragma mark View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self createPageViewController];
    
    // Init data
    [self initData];
}

- (void)viewDidAppear:(BOOL)animated; {
    [super viewDidAppear:NO];
}

- (void) createPageViewController {
    _contentTitle = @[@"Bem-Vindo",
                      @"Aprenda",
                      @"Adore",
                      @"Melhore"];
    _contentDescription = @[@"Vamos adorar a Deus melhor, juntos.",
                      @"Escute todos os hinos da harpa, use nosso metrônomo e afinador enquanto vocé toca.",
                      @"Use o app offline. tocar na igreja, ensaiar ou fazer seu devocional.",
                      @"Veja recursos, artigos, livros digitais e muito mais em nosso site harpacca.com."];
    
    UIPageViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier: @"PageController"];
    pageController.dataSource = self;
    if([_contentTitle count]) {
        NSArray *startingViewControllers = @[[self itemControllerForIndex: 0]];
        [pageController setViewControllers: startingViewControllers
                                 direction: UIPageViewControllerNavigationDirectionForward
                                  animated: NO
                                completion: nil];
    }
    _pageViewController = pageController;
    [[_pageViewController view] setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, [[self view] bounds].size.height + 37)];
    [_pageViewController view].backgroundColor = [UIColor clearColor];
    [self addChildViewController: _pageViewController];
    [self.view addSubview: _pageViewController.view];
    [_pageViewController didMoveToParentViewController: self];
    [self.view bringSubviewToFront:_pageControl];
}

#pragma mark - Init data
- (void)initData {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[BaseApi client] getJSON:nil headers:nil toUri:@"http://harpacca.com/mobile_get_songs.php" onSuccess:^(id data, id header) {
        NSDictionary *dictData = (NSDictionary *)data;
        if (dictData) {
            NSArray *arrayData = dictData[@"data"];
            for (NSDictionary *dictItem in arrayData) {
                NSString *title = dictItem[@"post_title"];
                NSArray *arrayString = [title componentsSeparatedByString:@" - "];
                NSString *songID = arrayString[0];
                NSString *songTitle = arrayString[1];
                NSString *songChord = dictItem[@"post_content"];
                NSString *songLink = dictItem[@"audio_url"];
                
                CDSong *song = [CDSong getOrCreateSongWithId:[songID intValue]];
                song.cdTitle = songTitle;
                song.cdChord = songChord;
                song.cdSongLink = songLink;
                [CDSong saveContext];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }onError:^(NSInteger code, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    // Set today to be the initial value for last_update_time
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *stringCurrentDate = [dateFormatter stringFromDate:[NSDate date]];
    [standardUserDefaults setObject:stringCurrentDate forKey:@"last_update_time"];
    [standardUserDefaults synchronize];
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
    if (itemController.itemIndex < [_contentTitle count] - 1) {
        return [self itemControllerForIndex: itemController.itemIndex + 1];
    }
    return nil;
}

- (PageItemViewController *)itemControllerForIndex:(NSUInteger)itemIndex {
    if (itemIndex < [_contentTitle count]) {
        PageItemViewController *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier: @"ItemController"];
        pageItemController.itemIndex = itemIndex;
        pageItemController.titleString = _contentTitle[itemIndex];
        pageItemController.descriptionString = _contentDescription[itemIndex];
        return pageItemController;
    }
    return nil;
}

#pragma mark -
#pragma mark Page Indicator

- (NSInteger) presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    _pageControl.numberOfPages = _contentTitle.count;
    return [_contentTitle count] ;
}

- (NSInteger) presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end
