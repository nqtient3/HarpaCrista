//
//  FavoritosViewController.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "FavoritosViewController.h"
#import "CDSong.h"
#import "HinosDetailViewController.h"

@interface FavoritosViewController () <UITableViewDataSource,UITableViewDelegate, UISearchBarDelegate> {
    NSArray *_arrayFavoriteSongs;
    __weak IBOutlet UITableView *_favoritosTableView;
    __weak IBOutlet UIView *_searchView;
    __weak IBOutlet UISearchBar *_searchBar;
    UITapGestureRecognizer *_tapGestureRecognizer;
}
@end

@implementation FavoritosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _searchBar.barTintColor = nil;
    _searchBar.tintColor = [UIColor grayColor];
    _searchBar.delegate = self;
    
    _arrayFavoriteSongs = [CDSong getAllFavoriteSongs];
    
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
    _arrayFavoriteSongs = [CDSong getAllFavoriteSongs];
    [_favoritosTableView reloadData];
}

- (void)starButtonClicked:(UIButton*)sender {
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [_favoritosTableView indexPathForCell:cell];
    CDSong *songItem = _arrayFavoriteSongs[indexPath.row];
    [CDSong makeSongWithSongID:[songItem.cdSongID intValue] isFavorite:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FavoriteListChange" object:nil];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrayFavoriteSongs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"customFavoritoCell";
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
    CDSong *songItem = _arrayFavoriteSongs[indexPath.row];
    
    UILabel *indexLabel = (UILabel *)[cell viewWithTag:1];
    indexLabel.text = [NSString stringWithFormat:@"%i", [songItem.cdSongID intValue]];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:3];
    nameLabel.text = songItem.cdTitle;
    
    UIButton *starButton = (UIButton *)[cell viewWithTag:4];
    [starButton addTarget:self action:@selector(starButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CDSong *currentSongItem = _arrayFavoriteSongs[indexPath.row];
    [self performSegueWithIdentifier:@"showFavoritosDetail" sender:currentSongItem];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    _arrayFavoriteSongs = [CDSong getAllFavoriteSongsWithKeyword:searchText];
    [_favoritosTableView reloadData];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFavoritosDetail"]) {
        HinosDetailViewController *hinosDetailVC = segue.destinationViewController;
        hinosDetailVC.currentCDSong = sender;
    }
}

@end
