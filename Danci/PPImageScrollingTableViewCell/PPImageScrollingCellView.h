//
//  PPImageScrollingCellView.h
//  PPImageScrollingTableViewDemo
//
//  Created by popochess on 13/8/9.
//  Copyright (c) 2013年 popochess. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PPCollectionViewCell.h"

@class PPImageScrollingCellView;

@protocol PPImageScrollingViewDelegate <NSObject>

- (void)collectionView:(PPImageScrollingCellView *)collectionView didSelectImageItemAtIndexPath:(NSIndexPath*)indexPath;

@end


@interface PPImageScrollingCellView : UIView

@property (weak, nonatomic) id<PPImageScrollingViewDelegate> delegate;

@property (strong, nonatomic) PPCollectionViewCell *myCollectionViewCell;
@property (strong, nonatomic) UICollectionView *myCollectionView;
@property (strong, nonatomic) NSArray *collectionImageData;

- (void) setImageData:(NSArray*)images;
- (void) setBackgroundColor:(UIColor*)color;

@end
