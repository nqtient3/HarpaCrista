// MEMenuViewController.m
// TransitionFun
//
// Copyright (c) 2013, Michael Enriquez (http://enriquez.me)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MEMenuViewController.h"
#import "MenuSlideBarTableViewCell.h"

static MEMenuViewController *__shared = nil;

@interface MEMenuViewController ()<UITableViewDataSource,UITableViewDelegate> {
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UILabel *_lblTitle;
    
    NSArray *_arrayMenuItems;
}

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation MEMenuViewController

- (void)viewDidLoad {
    _arrayMenuItems = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SlideMenuItems" ofType:@"plist"]] mutableCopy];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return 5;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = _arrayMenuItems[indexPath.section*5 + indexPath.row];
    
    static NSString *cellIdentifier = @"MenuSlideBarTableViewCell";
    MenuSlideBarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[MenuSlideBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    cell.lblTitle.text = dict[@"title"];
    cell.lblTitle.font = [UIFont systemFontOfSize:14];
    cell.imvIcon.image  = [UIImage imageNamed:dict[@"icon"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 44;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"Harpa Cristã com Acordes © 2016";
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                
                break;
            case 1:
                
                break;
            case 2:
                
                break;
            case 3:
                
                break;
            case 4:
                [self performSegueWithIdentifier:@"goToMais" sender:nil];
                break;
                
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                
                break;
            case 1:
                
                break;
            case 2:
                
                break;
            case 3:
                
                break;
            case 4:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://harpacca.com/"]];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Storyboard prepare segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goToMais"]) {
        NSLog(@"about");
    }
    else if ([segue.identifier isEqualToString:@"upgradeAccount"]) {
        NSLog(@"upgradeAccount");
    }
}

@end
