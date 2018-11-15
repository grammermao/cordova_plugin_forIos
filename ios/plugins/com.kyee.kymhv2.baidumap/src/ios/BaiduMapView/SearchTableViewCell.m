//
//  SearchTableViewCell.m
//  Route
//
//  Created by Zhu Xueliang on 15/6/19.
//  Copyright (c) 2015年 Zhu Xueliang. All rights reserved.
//

#import "SearchTableViewCell.h"

@implementation SearchTableViewCell

@synthesize headerImg = _headerImg;
@synthesize hospitalName = _hospitalName;
@synthesize hospitalAddr = _hospitalAddr;

- (id)init {
    self = [super init];
    if (self) {
        self.headerImg = [[UIImageView alloc] initWithFrame: CGRectMake(10, 26, 20, 20)];
        [self.contentView addSubview: self.headerImg];
        
        self.hospitalName = [[UILabel alloc] initWithFrame: CGRectMake(40, 4, [[UIScreen mainScreen] bounds].size.width - 50, 30)];
        [self.contentView addSubview:self.hospitalName];
        
        self.hospitalAddr = [[UILabel alloc] initWithFrame:CGRectMake(40, 38, [[UIScreen mainScreen] bounds].size.width - 50, 30)];
        [self.contentView addSubview:self.hospitalAddr];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
