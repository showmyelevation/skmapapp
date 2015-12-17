//
//  TextDisclosure.m
//  MapTest
//
//  Created by BogdanB on 12/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "TextDisclosure.h"

@implementation TextDisclosure

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(3.0, self.closeButton.frame.size.height, self.frame.size.width - 6.0, self.frame.size.height - self.closeButton.frame.size.height - 3.0)];
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textView.delegate = self;
        [self addSubview:self.textView];
        self.contentView.scrollEnabled = NO;
    }
    
    return self;
}

- (void)setItem:(MenuItem *)item {
    [super setItem:item];
    _textView.text = [NSString stringWithFormat:@"%@", self.item.value];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.item.value = textView.text;
    if (self.item.editEndBlock) {
        self.item.editEndBlock(self.item, self.item.value);
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    self.item.value = textView.text;
}

+ (instancetype)textDisclosureWithItem:(MenuItem *)item frame:(CGRect)frame {
    TextDisclosure *disclosure = [[TextDisclosure alloc] initWithFrame:frame];
    disclosure.item = item;
    
    return disclosure;
}

@end
