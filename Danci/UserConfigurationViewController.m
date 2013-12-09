//
//  UserConfigurationViewController.m
//  Danci
//
//  Created by zhenghao on 12/3/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import "UserConfigurationViewController.h"

@interface UserConfigurationViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation UserConfigurationViewController

@synthesize danciDatabase = _danciDatabase;
@synthesize user = _user;

@synthesize tableViewUserInfo;


//- (UserInfo *) user
//{
//    if(_user == nil){
//        _user = [UserInfo getUser:self.danciDatabase.managedObjectContext];
//    }
//    return _user;
//}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = @"用户信息";
    
    [tableViewUserInfo setDelegate:self];
    [tableViewUserInfo setDataSource:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tableCellUserInfo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *abstractInfo = @"";
    NSString *detailInfo = @"";
    
    switch (indexPath.row) {
        case 0:
        abstractInfo = @"当前用户";
        detailInfo = self.user.mid;
        break;
        
        case 1:
        abstractInfo = @"学号";
        detailInfo = [NSString stringWithFormat:@"%@", self.user.studyNo];
        break;
        
        case 2:
        abstractInfo = @"单词上限";
        detailInfo = [NSString stringWithFormat:@"%@", self.user.maxWordNum];
        break;
        
        case 3:
        abstractInfo = @"已学习单词";
        detailInfo = [NSString stringWithFormat:@"%@", self.user.comsumeWordNum];
        break;
        
        case 4:
        abstractInfo = @"注册时间";
        detailInfo = [NSString stringWithFormat:@"%@", self.user.regTime];
        break;
        
        case 5:
        abstractInfo = @"推荐者学号";
        detailInfo = [NSString stringWithFormat:@"%@", self.user.recommendStudyNo];
        break;
        
        default:
        break;
    }
    
    cell.textLabel.text = abstractInfo;
    cell.detailTextLabel.text = detailInfo;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
