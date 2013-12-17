//
//  PPCollectionViewCell.m
//  PPImageScrollingTableViewControllerDemo
//
//  Created by popochess on 13/8/10.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import "PPCollectionViewCell.h"

@interface PPCollectionViewCell ()

@end

@implementation PPCollectionViewCell

@synthesize imageView = _imageView;
@synthesize imageTitle = _imageTitle;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., frame.size.width, frame.size.height)];
    }
    return self;
}

-(void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    if ([self.contentView subviews]){
        for (UILabel *subview in [self.contentView subviews]) {
            [subview removeFromSuperview];
        }
    }
    [self.contentView addSubview:self.imageView];
}

@end
