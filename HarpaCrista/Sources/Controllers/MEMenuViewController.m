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

static MEMenuViewController *__shared = nil;

@interface MEMenuViewController ()<UITableViewDataSource,UITableViewDelegate>
{
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return _arrayMenuItems.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"StandardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    NSDictionary *dict = _arrayMenuItems[indexPath.section*5 + indexPath.row];
    cell.textLabel.text = dict[@"title"];
    if (indexPath.section < 2) {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.imageView.frame = CGRectMake(0, 0, 40, 40);
        cell.imageView.image  = [UIImage imageNamed:dict[@"icon"]];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:11];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 44;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Storyboard prepare segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"about"]) {
        NSLog(@"about");
    }
    else if ([segue.identifier isEqualToString:@"upgradeAccount"]) {
        NSLog(@"upgradeAccount");
    }
}

@end
