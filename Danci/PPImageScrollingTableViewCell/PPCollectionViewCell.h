//
//  PPCollectionViewCell.h
//  PPImageScrollingTableViewControllerDemo
//
//  Created by popochess on 13/8/10.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *imageTitle;

- (void)setImage:(UIImage*) image;
//- (void)setTitle:(NSString*) title;
//- (void) setImageTitleLabelWitdh:(CGFloat)width withHeight:(CGFloat)height;
//- (void) setImageTitleTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)bgColor;
@end
