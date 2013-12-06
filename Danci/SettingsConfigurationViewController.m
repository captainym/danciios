//
//  SettingsConfigurationViewController.m
//  Danci
//
//  Created by zhenghao on 12/4/13.
//  Copyright (c) 2013 mx. All rights reserved.
//

#import "SettingsConfigurationViewController.h"

@interface SettingsConfigurationViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@end

@implementation SettingsConfigurationViewController

@synthesize actionSheet;
@synthesize studyTime = _studyTime;

@synthesize tableViewSettings;

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
    
    self.title = @"配置";
    
    [tableViewSettings setDelegate:self];
    [tableViewSettings setDataSource:self];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *CellIdentifier = @"tableCellWordStudyCount";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *settingsName = @"";
    NSString *settingsValue = @"";
    
    switch (indexPath.row) {
        case 0:
            settingsName = @"每日学习单词量:";
            settingsValue = @"30";
            break;
            
        case 1:
            settingsName = @"每日复习单词量:";
            settingsValue = @"100";
            break;
            
        case 2:
            settingsName = @"每日学习单词时间:";
            settingsValue = @"09:00";
            break;
            
        default:
            break;
    }
    
    cell.textLabel.text = settingsName;
    
    CGRect textFieldRect = CGRectMake(100.0, 0.0f, 100.0f, 31.0f);
    UITextField *theTextField = [[UITextField alloc] initWithFrame:textFieldRect];
    theTextField.borderStyle = UITextBorderStyleRoundedRect;
    theTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    theTextField.returnKeyType = UIReturnKeyDone;
    theTextField.secureTextEntry = FALSE;
    theTextField.clearButtonMode = YES;
    theTextField.tag = row;
    theTextField.delegate = self;
    
    [theTextField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    if (indexPath.row == 2) {
        [theTextField addTarget:self action:@selector(didBeginEditingStudyTime:) forControlEvents:UIControlEventEditingDidBegin];
        self.studyTime = theTextField;
    }
    
    theTextField.text = settingsValue;
    
    cell.accessoryView = theTextField;
    
    return cell;
}

- (void) checkValue: (UITextField *)textField
{
    NSString *defaultValue = @"";
    
    switch (textField.tag) {
        case 0:
            defaultValue = @"30";
            break;

        case 1:
            defaultValue = @"100";
            break;
            
        case 2:
            defaultValue = @"09:00";
            break;
            
        default:
            break;
    }
    
    if ([textField.text isEqualToString: @""]) {
        textField.text = defaultValue;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self checkValue: textField];
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [self checkValue: textField];
//}

- (void)didBeginEditingStudyTime:(UITextField *)textField
{
    if (textField.tag != 2) {
        return;
    }
    
    [textField resignFirstResponder];
    
    if (actionSheet == nil) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    }
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    datePicker.datePickerMode = UIDatePickerModeTime;
    datePicker.hidden = NO;
    
    // 设置DatePick的初始值
    NSString *defaultValue = @"09:00";
    NSString *dateString = [textField.text isEqualToString:@""] ? defaultValue : textField.text;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    datePicker.date = [dateFormatter dateFromString:dateString];
    
    [datePicker addTarget:self action:@selector(updateStudyTime:) forControlEvents:UIControlEventValueChanged];

    [textField setInputView:datePicker];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];
    closeButton.momentary = YES;
    closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
    closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
    closeButton.tintColor = [UIColor blackColor];
    [closeButton addTarget:self action:@selector(cancelEditStudyTime:) forControlEvents:UIControlEventValueChanged];
    [actionSheet addSubview:closeButton];

    [actionSheet addSubview:closeButton];
    [actionSheet addSubview:datePicker];
    [actionSheet showInView:self.view];
    
    [actionSheet setBounds:CGRectMake(0, 0, 320, 464)];
}

-(void)doneEditStudyTime:(id)sender{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)cancelEditStudyTime:(id)sender{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)updateStudyTime:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)sender;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    self.studyTime.text = [dateFormatter stringFromDate: picker.date];
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
