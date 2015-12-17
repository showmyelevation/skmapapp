//
//  TextDisclosure.h
//  MapTest
//
//  Created by BogdanB on 12/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "DisclosureView.h"
#import "MenuItem.h"

@interface TextDisclosure : DisclosureView <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

+ (instancetype)textDisclosureWithItem:(MenuItem *)item frame:(CGRect)frame;

@end
