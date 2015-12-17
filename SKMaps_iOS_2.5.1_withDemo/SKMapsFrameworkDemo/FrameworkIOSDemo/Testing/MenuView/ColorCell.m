//
//  ColorCell.m
//  FrameworkIOSDemo
//
//  Created by BogdanB on 20/04/15.
//  Copyright (c) 2015 Skobbler. All rights reserved.
//

#import "ColorCell.h"
#include "UIView+Additions.h"
#import "MenuItem.h"

@interface ColorCell ()

@property (nonatomic, strong) UISlider *red;
@property (nonatomic, strong) UILabel *redLabel;
@property (nonatomic, strong) UISlider *green;
@property (nonatomic, strong) UILabel *greenLabel;
@property (nonatomic, strong) UISlider *blue;
@property (nonatomic, strong) UILabel *blueLabel;
@property (nonatomic, strong) UISlider *alphaSlider;
@property (nonatomic, strong) UILabel *alphaLabel;
@property (nonatomic, strong) UIView *colorView;

@end

@implementation ColorCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self addViews];
    }
    
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    self.red.value = r * 255.0;
    self.green.value = g * 255.0;
    self.blue.value = b * 255.0;
    self.alphaSlider.value = a * 255.0;
    
    self.redLabel.text = [NSString stringWithFormat:@"Red: %.1f", self.red.value];
    self.greenLabel.text = [NSString stringWithFormat:@"Green: %.1f", self.green.value];
    self.blueLabel.text = [NSString stringWithFormat:@"Blue: %.1f", self.blue.value];
    self.alphaLabel.text = [NSString stringWithFormat:@"Alpha: %.1f", self.alphaSlider.value];
    
    self.colorView.backgroundColor = color;
}

- (UISlider *)colorSlider {
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10.0, 0.0, self.contentView.frameWidth - 20.0, 30.0)];
    slider.continuous = YES;
    slider.minimumValue = 0.0;
    slider.maximumValue = 255.0;
    slider.value = 0.0;
    slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [slider addTarget:self action:@selector(colorValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.contentView addSubview:slider];
    
    return slider;
}

- (void)touch {
    NSLog(@"tap");
}

- (UILabel *)createLabel {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.contentView.frameWidth - 20.0, 20.0)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont systemFontOfSize:12.0];
    
    [self.contentView addSubview:label];
    
    return label;
}

- (void)addViews {
    self.titleLabel = [self createLabel];
    
    self.redLabel = [self createLabel];
    self.redLabel.text = @"Red: 0";
    self.redLabel.frameY = self.titleLabel.frameMaxY;
    
    self.red = [self colorSlider];
    self.red.frameY = self.redLabel.frameMaxY;
    
    self.greenLabel = [self createLabel];
    self.greenLabel.text = @"Green: 0";
    self.greenLabel.frameY = self.red.frameMaxY;
    
    self.green = [self colorSlider];
    self.green.frameY = self.greenLabel.frameMaxY;
    
    self.blueLabel = [self createLabel];
    self.blueLabel.text = @"Blue: 0";
    self.blueLabel.frameY = self.green.frameMaxY;
    
    self.blue = [self colorSlider];
    self.blue.frameY = self.blueLabel.frameMaxY;
    
    self.alphaLabel = [self createLabel];
    self.alphaLabel.text = @"Alpha: 0";
    self.alphaLabel.frameY = self.blue.frameMaxY;
    
    self.alphaSlider = [self colorSlider];
    self.alphaSlider.frameY = self.alphaLabel.frameMaxY;
}

- (void)colorValueChanged:(UISlider *)slider {
    _color = [UIColor colorWithRed:self.red.value / 255.0 green:self.green.value / 255.0 blue:self.blue.value / 255.0 alpha:self.alphaSlider.value / 255.0];
    self.colorView.backgroundColor = self.color;
    
    if (slider == self.red) {
        self.redLabel.text = [NSString stringWithFormat:@"Red: %.1f", self.red.value];
    } else if (slider == self.green) {
        self.greenLabel.text = [NSString stringWithFormat:@"Green: %.1f", self.green.value];
    } else if (slider == self.blue) {
        self.blueLabel.text = [NSString stringWithFormat:@"Blue: %.1f", self.blue.value];
    } else {
        self.alphaLabel.text = [NSString stringWithFormat:@"Alpha: %.1f", self.alphaSlider.value];
    }
    
    self.item.value = self.color;
}

@end
