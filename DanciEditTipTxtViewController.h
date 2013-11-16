//
//  DanciEditTipTxtViewController.h
//  Danci
//
//  Created by HuHao on 13-11-16.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DanciEditTipTxtViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *txtTipTxtEditor;
@property (weak, nonatomic) IBOutlet UILabel *lblMeaningStemTip;

@property (nonatomic, strong) NSString *word;
@property (nonatomic, strong) NSString *meaningstem;
//用户之前写的助记 可以为空
@property (nonatomic, strong) NSString *tipTxtOld;
@property (nonatomic, strong) NSString *tipTxtNew;

@end
