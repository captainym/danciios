//
//  DanciEditTipTxtViewController.m
//  Danci
//
//  Created by HuHao on 13-11-16.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import "DanciEditTipTxtViewController.h"

@interface DanciEditTipTxtViewController () <UITextViewDelegate>

@end

@implementation DanciEditTipTxtViewController

@synthesize word = _word;
@synthesize meaningstem = _meaningstem;
@synthesize tipTxtNew = _tipTxtNew;
@synthesize tipTxtOld = _tipTxtOld;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if([self.tipTxtOld length] > 1)
    {
        self.txtTipTxtEditor.text = self.tipTxtOld;
    }
    self.lblMeaningStemTip.text = self.meaningstem;
    self.title = self.word;
    self.txtTipTxtEditor.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//保存编辑的文字助记 并
- (IBAction)saveTipTxt:(UIButton *)sender {
    NSString *newtip = self.txtTipTxtEditor.text;
    //验证是否合格
    if([newtip length] > 2 && newtip.length < 140){
        NSLog(@"save the tip[%@]", newtip);
    }else{
        NSLog(@"tip is to shoot to save");
    }
    //返回
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return TRUE;
}

@end
