//
//  DanciEditTipTxtViewController.h
//  Danci
//
//  Created by ShiYuming on 13-11-16.
//  Copyright (c) 2013年 mx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DanciServer.h"
#import "Word.h"

@class DanciEditTipTxtViewController;

@protocol DanciEditTipTxtDelegate <NSObject>

//完成编辑后 把编辑好的文字助记更新到单词界面 代理post数据上server post失败则保存在本地
-(void) eidtTipTxt:(DanciEditTipTxtViewController *) sender
   didEditTipTxtOk:(NSDictionary *) callbackdata
     operationType:(StudyOperationType) otype;

@end

@interface DanciEditTipTxtViewController : UIViewController
{
    //数据控件
    UITableView *tblTipstxt;
    UITextView *txtEditTip;
    UILabel *lbltip;
    UIButton *btnOK;
    
    //滑动控件
    UIPageControl *pageControl;
    int curPage;
    BOOL pageControlUsed;
}

@property (nonatomic, weak) id<DanciEditTipTxtDelegate> delegate;

@property (nonatomic, strong) UIManagedDocument *danciDatabase;
@property (nonatomic, strong) Word *curWord;

//控件
@property (weak, nonatomic) IBOutlet UIButton *btnAdopTip;
@property (weak, nonatomic) IBOutlet UIButton *btnEditTip;
@property (weak, nonatomic) IBOutlet UILabel *lblPink;
@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

@end
