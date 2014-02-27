//
//  MasterViewController.m
//  OnoScrapingSample
//
//  Created by griffin-stewie on 2014/02/27.
//  Copyright (c) 2014年 net.cyan-stivy. All rights reserved.
//

#import "MasterViewController.h"
#import "AFNetworking.h"
#import "Ono.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *URL = @"http://guides.cocoapods.org/";
    self.navigationItem.title = URL;
   
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    __weak typeof(self) weakSelf = self;
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSError *error = nil;
        ONOXMLDocument *doc = [ONOXMLDocument HTMLDocumentWithData:responseObject error:&error];
        [doc enumerateElementsWithCSS:@"h5" block:^(ONOXMLElement *element) {
            [strongSelf addElement:element];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)addElement:(ONOXMLElement *)element
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects addObject:element];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    ONOXMLElement *element = _objects[indexPath.row];
    cell.textLabel.text = [element stringValue];
    cell.detailTextLabel.text = [element firstChildWithTag:@"a"][@"href"];
    return cell;
}
@end
