//
//  SliderCell.m
//  MapTest
//
//  Created by BogdanB on 12/11/14.
//  Copyright (c) 2014 Skobbler. All rights reserved.
//

#import "SliderCell.h"
#import "MenuItem.h"

@implementation SliderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSlider];
    }
    
    return  self;
}

- (void)addSlider {
    self.slider = [[UISlider alloc] initWithFrame:CGRectZero];
    [self.slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.slider];
}

- (void)valueChanged:(UISlider *)slider {
    if (self.item.integerSlider) {
        slider.value = roundf(slider.value);
    }
    self.item.value = @(slider.value);
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@", @(slider.value)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 5.0, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, 5.0, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
    
    self.slider.frame = CGRectMake(10.0, 40.0, self.contentView.frame.size.width - 20.0, 20.0);
}

@end
