//
//  PPImageScrollingCellView.m
//  PPImageScrollingTableViewDemo
//
//  Created by popochess on 13/8/9.
//  Copyright (c) 2013年 popochess. All rights reserved.
//

#import "PPImageScrollingCellView.h"
#import "DanciServer.h"

@interface  PPImageScrollingCellView () <UICollectionViewDataSource, UICollectionViewDelegate>

//@property (nonatomic) CGFloat imagetitleWidth;
//@property (nonatomic) CGFloat imagetitleHeight;
//@property (strong, nonatomic) UIColor *imageTilteBackgroundColor;
//@property (strong, nonatomic) UIColor *imageTilteTextColor;

@end

@implementation PPImageScrollingCellView

@synthesize myCollectionView = _myCollectionView;
@synthesize myCollectionViewCell = _myCollectionViewCell;
@synthesize collectionImageData = _collectionImageData;

- (id)initWithFrame:(CGRect)frame
{
     self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code

        /* Set flowLayout for CollectionView*/
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(94.0, 94.0);
        flowLayout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
        flowLayout.minimumLineSpacing = 10;

        /* Init and Set CollectionView */
        self.myCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        self.myCollectionView.delegate = self;
        self.myCollectionView.dataSource = self;
        self.myCollectionView.showsHorizontalScrollIndicator = NO;

        [self.myCollectionView registerClass:[PPCollectionViewCell class] forCellWithReuseIdentifier:@"PPCollectionCell"];
        [self addSubview:_myCollectionView];
    }
    return self;
}

- (void) setImageData:(NSArray*)collectionImageData{
    _collectionImageData = collectionImageData;
    [_myCollectionView reloadData];
}

- (void) setBackgroundColor:(UIColor*)color{

    self.myCollectionView.backgroundColor = color;
    [_myCollectionView reloadData];
}

/*
- (void) setImageTitleLabelWitdh:(CGFloat)width withHeight:(CGFloat)height{
    _imagetitleWidth = width;
    _imagetitleHeight = height;
}
- (void) setImageTitleTextColor:(UIColor*)textColor withBackgroundColor:(UIColor*)bgColor{
    
    _imageTilteTextColor = textColor;
    _imageTilteBackgroundColor = bgColor;
}*/

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionImageData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PPCollectionViewCell *cell = (PPCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PPCollectionCell" forIndexPath:indexPath];
    NSDictionary *imageDic = [self.collectionImageData objectAtIndex:[indexPath row]];
    
    NSString *imgurl = [imageDic objectForKey:TIPS_IMG_URL];
//    NSLog(@"now load img with url:[%@]",imgurl);
    dispatch_queue_t downloadImg = dispatch_queue_create("download one img", NULL);
    dispatch_async(downloadImg, ^{
        NSURL *imgurlnet = [NSURL URLWithString:imgurl];
        NSData *imgData = [NSData dataWithContentsOfURL:imgurlnet];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithData:imgData];
            [cell setImage:image];
        });
    });
//    [cell setImage:[UIImage imageNamed:[imageDic objectForKey:@"url"]]];
//    [cell setImageTitleLabelWitdh:_imagetitleWidth withHeight:_imagetitleHeight];
//    [cell setImageTitleTextColor:_imageTilteTextColor withBackgroundColor:_imageTilteBackgroundColor];
//    [cell setTitle:[imageDic objectForKey:@"title"]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.delegate collectionView:self didSelectImageItemAtIndexPath:(NSIndexPath*)indexPath];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
