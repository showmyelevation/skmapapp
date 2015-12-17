//
//  TextCell.m
//  CoreDemo
//
//  Created by BogdanB on 22/01/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "TextCell.h"

@interface TextCell () <UITextViewDelegate>

@end

@implementation TextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addTextField];
    }
    
    return self;
}

- (void)addTextField {
    self.field = [[UITextView alloc] initWithFrame:CGRectZero];
    self.field.delegate = self;
    self.field.backgroundColor = [UIColor whiteColor];
    self.field.textColor = [UIColor grayColor];
    self.field.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.field];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 5.0, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    
    self.field.frame = CGRectMake(10.0, 23.0, self.contentView.frame.size.width - 20.0, 40.0);
}

- (void)textViewDidChange:(UITextView *)textView {
    self.item.value = textView.text;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UITableView *tView = (UITableView *)self.superview.superview;
    [tView scrollToRowAtIndexPath:[tView indexPathForCell:self] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.item.editEndBlock) {
        self.item.editEndBlock(self.item, self.item.value);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
