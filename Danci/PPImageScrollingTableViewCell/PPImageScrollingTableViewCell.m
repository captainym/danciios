//
//  PPScrollingTableViewCell.m
//  PPImageScrollingTableViewControllerDemo
//
//  Created by popochess on 13/8/10.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import "PPImageScrollingTableViewCell.h"

#define kScrollingViewHieght 96
//#define kCategoryLabelWidth 200
//#define kCategoryLabelHieght 30
#define kStartPointY 0

@interface PPImageScrollingTableViewCell() <PPImageScrollingViewDelegate>

//@property (strong,nonatomic) UIColor *categoryTitleColor;
//@property (strong, nonatomic) NSString *categoryLabelText;

@end

@implementation PPImageScrollingTableViewCell

@synthesize imageScrollingView = _imageScrollingView;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize
{
    // Set ScrollImageTableCellView
    self.imageScrollingView = [[PPImageScrollingCellView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320., kScrollingViewHieght)];
    self.imageScrollingView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setImageData:(NSArray *)images
{
    [self.imageScrollingView setImageData: images];
    
    if ([self.contentView subviews]){
        for (UIView *subview in [self.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    [self.contentView addSubview:_imageScrollingView];
    //_categoryLabelText = [collectionImageData objectForKey:@"category"];
}

- (void)setCollectionViewBackgroundColor:(UIColor *)color{
    self.imageScrollingView.backgroundColor = color;
}

#pragma mark - PPImageScrollingViewDelegate

- (void)collectionView:(PPImageScrollingCellView *)collectionView didSelectImageItemAtIndexPath:(NSIndexPath*)indexPath {
    
    [self.delegate scrollingTableViewCell:self didSelectImageAtIndexPath:indexPath];
}

@end
