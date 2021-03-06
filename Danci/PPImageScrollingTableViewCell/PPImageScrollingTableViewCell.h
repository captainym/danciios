//
//  PPScrollingTableViewCell.h
//  PPImageScrollingTableViewControllerDemo
//
//  Created by popochess on 13/8/10.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPImageScrollingCellView.h"
@class PPImageScrollingTableViewCell;

@protocol PPImageScrollingTableViewCellDelegate <NSObject>

// Notifies the delegate when user click image
- (void)scrollingTableViewCell:(PPImageScrollingTableViewCell *)sender didSelectImageAtIndexPath:(NSIndexPath*)indexPathOfImage;

@end

@interface PPImageScrollingTableViewCell : UITableViewCell

@property(strong, nonatomic) PPImageScrollingCellView *imageScrollingView;
@property (weak, nonatomic) id<PPImageScrollingTableViewCellDelegate> delegate;
@property (nonatomic) CGFloat height;

- (void) setImageData:(NSArray *) image;
- (void) setCollectionViewBackgroundColor:(UIColor*) color;

@end