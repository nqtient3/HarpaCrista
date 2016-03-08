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

@interface HinosViewController ()<UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate> {
    NSArray *_arraySongs;
    __weak IBOutlet UIView *_searchView;
    __weak IBOutlet UISearchBar *_searchBar;
    __weak IBOutlet UITableView *_hinosTableView;
    UITapGestureRecognizer *_tapGestureRecognizer;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
