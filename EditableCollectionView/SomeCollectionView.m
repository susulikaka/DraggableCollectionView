//
//  SomeCollectionView.m
//  EditableCollectionView
//
//  Created by SupingLi on 16/8/30.
//  Copyright © 2016年 SupingLi. All rights reserved.
//

#import "SomeCollectionView.h"

@implementation SomeCollectionView

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize]))
    {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = self.contentSize;
    
    return intrinsicContentSize;
}

@end
