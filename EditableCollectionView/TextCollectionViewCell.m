//
//  TextCollectionViewCell.m
//  EditableCollectionView
//
//  Created by SupingLi on 16/8/29.
//  Copyright © 2016年 SupingLi. All rights reserved.
//

#import "TextCollectionViewCell.h"

@interface TextCollectionViewCell ()<UITextViewDelegate>

@end

@implementation TextCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.text.delegate = self;
    self.text.backgroundColor = [UIColor redColor];
}

#pragma mark - private method

- (void)renderWithBlock:(void (^)(id obj))changeTextBlock {
    self.changeTextBlock = changeTextBlock;
}

#pragma mark - delegate

- (void)textViewDidChange:(UITextView *)textView {
    CGRect bounds = textView.bounds;
    CGSize maxSize = CGSizeMake(bounds.size.width, 10000);
    CGSize newSize = [textView sizeThatFits:maxSize];
    bounds.size = newSize;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"textChange" object:nil];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if (self.changeTextBlock) {
        self.changeTextBlock(textView.text);
    }
}

@end
