//
//  ViewController.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "HinosViewController.h"
#import "CDSong.h"
#import "HinosDetailViewController.h"
#import "CDSong.h"
#import "BaseApi.h"
#import "Reachability.h"
@import GoogleMobileAds;

@interface HinosViewController ()<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate, GADBannerViewDelegate> {
    NSArray *_arraySongs;
    __weak IBOutlet UIView *_searchView;
    __weak IBOutlet UISearchBar *_searchBar;
    __weak IBOutlet UITableView *_hinosTableView;
    UITapGestureRecognizer *_tapGestureRecognizer;
    
    __weak IBOutlet GADBannerView *_bannerView;
    
    __weak IBOutlet NSLayoutConstraint *_heightBannerConstraint;
}

@end

@implementation HinosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _searchBar.barTintColor = nil;
    _searchBar.tintColor = [UIColor grayColor];
    _searchBar.delegate = self;
    
    _arraySongs = [CDSong getAllSongs];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:@"FavoriteListChange" object:nil];
    
    // Listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    // Add tapGestureRecognizer for view to hide the keyboard
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                             initWithTarget:self
                             action:@selector(dismissKeyboard)];
    
    // Check and update the songs if there are any changes
    [self updateData];
    
    //Load Ads if the network is connectable
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        //Set height of banner to 0
        _heightBannerConstraint.constant = 0.0f;
    } else {
        [self loadGoogleAds];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GoogleAds - GADBannerViewDelegate
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    _bannerView.hidden = NO;
}

- (void)loadGoogleAds {
    _bannerView.hidden = YES;
    //Google AdMob
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    _bannerView.adUnitID = @"ca-app-pub-5569929039117299/9402430169";
    _bannerView.adSize = kGADAdSizeSmartBannerPortrait;
    _bannerView.rootViewController = self;
    _bannerView.delegate = self;
    
    [_bannerView loadRequest:[GADRequest request]];
}

#pragma mark - Update data
- (void)updateData {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastUpdateTime = [standardUserDefaults stringForKey:@"last_update_time"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *stringCurrentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [standardUserDefaults setObject:stringCurrentDate forKey:@"last_update_time"];
    [standardUserDefaults synchronize];
    
    NSDictionary *object = @{@"last_update_time":lastUpdateTime};
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[BaseApi client] getJSON:object headers:nil toUri:@"http://harpacca.com/mobile_get_songs.php" onSuccess:^(id data, id header) {
        NSDictionary *dictData = (NSDictionary *)data;
        if (dictData && ![dictData isEqual:[NSNull null]]) {
            NSArray *arrayData = dictData[@"data"];
            if (arrayData && ![arrayData isEqual:[NSNull null]] && arrayData.count > 0) {
                NSMutableArray *arrayChangedIndexPaths = [NSMutableArray array];
                for (NSDictionary *dictItem in arrayData) {
                    NSString *title = dictItem[@"post_title"];
                    NSArray *arrayString = [title componentsSeparatedByString:@" - "];
                    NSString *songID = arrayString[0];
                    [arrayChangedIndexPaths addObject:[NSIndexPath indexPathForRow:[songID intValue] inSection:0]];
                    NSString *songTitle = arrayString[1];
                    NSString *songChord = dictItem[@"post_content"];
                    NSString *songLink = dictItem[@"audio_url"];
                    
                    CDSong *song = [CDSong getOrCreateSongWithId:[songID intValue]];
                    song.cdTitle = songTitle;
                    song.cdChord = songChord;
                    song.cdSongLink = songLink;
                    [CDSong saveContext];
                }
                
                // Reload table data after updating songs
                _arraySongs = [CDSong getAllSongs];
                [_hinosTableView reloadRowsAtIndexPaths:arrayChangedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }onError:^(NSInteger code, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

#pragma mark - Actions
- (void)keyboardDidShow {
    [self.view addGestureRecognizer:_tapGestureRecognizer];
}

- (void)keyboardDidHide {
    [self.view removeGestureRecognizer:_tapGestureRecognizer];
}

- (void)dismissKeyboard {
    [_searchBar resignFirstResponder];
}

- (void)reloadTableView {
    _arraySongs = [CDSong getAllSongs];
    [_hinosTableView reloadData];
}

- (void)starButtonClicked:(UIButton*)sender {
    sender.selected = !sender.isSelected;
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [_hinosTableView indexPathForCell:cell];
    CDSong *songItem = _arraySongs[indexPath.row];
    [CDSong makeSongWithSongID:[songItem.cdSongID intValue] isFavorite:sender.isSelected];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FavoriteListChange" object:nil];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arraySongs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"customHinosCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    CDSong *songItem = _arraySongs[indexPath.row];
    
    UILabel *indexLabel = (UILabel *)[cell viewWithTag:1];
    indexLabel.text = [NSString stringWithFormat:@"%i", [songItem.cdSongID intValue]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:3];
    nameLabel.text = [NSString stringWithFormat:@"%@", songItem.cdTitle];
    
    UIButton *starButton = (UIButton *)[cell viewWithTag:4];
    starButton.selected = [songItem.cdIsFavorite boolValue];
    [starButton addTarget:self action:@selector(starButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     CDSong *currentSongItem = _arraySongs[indexPath.row];
    [self performSegueWithIdentifier:@"showHinosDetail" sender:currentSongItem];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _arraySongs = [CDSong getAllSongsWithKeyword:searchText];
    [_hinosTableView reloadData];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showHinosDetail"]) {
        HinosDetailViewController *hinosDetailVC = segue.destinationViewController;
        hinosDetailVC.currentCDSong = sender;
    }
}

@end
