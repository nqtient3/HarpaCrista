//
//  ViewController.m
//  HarpaCrista
//
//  Created by Chinh Le on 3/1/16.
//  Copyright © 2016 Chinh Le. All rights reserved.
//

#import "HinosViewController.h"
#import "CDSong.h"

@interface HinosViewController ()<UITableViewDataSource,UITableViewDelegate> {
    NSArray *_arraySongs;
}

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
@property (weak, nonatomic) IBOutlet UITableView *hinosTableView;

@end

@implementation HinosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.searchBar.barTintColor = nil;
    self.searchBar.tintColor = [UIColor grayColor];
    
    _arraySongs = [CDSong getAllSongs];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)starButtonClicked:(UIButton*)sender {
    sender.selected = !sender.isSelected;
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview;
    NSIndexPath *indexPath = [self.hinosTableView indexPathForCell:cell];
    CDSong *songItem = _arraySongs[indexPath.row];
    [CDSong makeSongWithSongID:[songItem.cdSongID intValue] isFavorite:sender.isSelected];
    
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

@end
