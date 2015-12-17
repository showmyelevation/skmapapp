//
//  DisclosureView.m
//  DemoiOS
//
//  Created by BogdanB on 11/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "DisclosureView.h"
#import "MenuItem.h"
#import "UIView+Additions.h"

@interface AutomaticScrollView : UIScrollView

@end

@implementation DisclosureView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor lightGrayColor];
        
        [self addTopView];
        [self addCloseButton];
        [self addTitleLabel];
        [self addContentView];
    }
    
    return self;
}

- (void)setItem:(MenuItem *)item {
    _item = item;
    self.titleLabel.text = item.title;
}

- (void)addTopView {
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth, kDisclosureButtonSize)];
    self.topView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.topView];
}

- (void)addCloseButton {
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setTitle:@"X" forState:UIControlStateNormal];
    self.closeButton.frame = CGRectMake(self.topView.frameWidth - kDisclosureButtonSize, 0.0, kDisclosureButtonSize, kDisclosureButtonSize);
    self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    self.closeButton.backgroundColor = [UIColor lightGrayColor];
    [self.closeButton addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.closeButton];
}

- (void)addTitleLabel {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frameWidth - kDisclosureButtonSize, kDisclosureButtonSize)];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:self.titleLabel];
}

- (void)addContentView {
    self.contentView = [[AutomaticScrollView alloc] initWithFrame:CGRectMake(0.0, self.topView.frameMaxY, self.frameWidth, self.frameHeight - self.topView.frameMaxY)];
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.showsHorizontalScrollIndicator = YES;
    [self addSubview:self.contentView];
}

- (void)closeClicked {
    if ([self.delegate respondsToSelector:@selector(disclosureViewDidClose:)]) {
        [self.delegate disclosureViewDidClose:self];
    }
}

@end

@implementation AutomaticScrollView

- (void)addSubview:(UIView *)view {
    [super addSubview:view];

    [self updateContentForView:view];
}

- (void)updateContentForView:(UIView *)view {
    CGSize size = self.contentSize;
    if (view.frameMaxX > size.width) {
        size.width = view.frameMaxX;
    }
    
    if (view.frameMaxY > size.height) {
        size.height = view.frameMaxY;
    }
    
    self.contentSize = size;
}

@end
