//
//  RouteTableViewCell.m
//  Route
//
//  Created by Zhu Xueliang on 15/6/19.
//  Copyright (c) 2015年 Zhu Xueliang. All rights reserved.
//

#import "RouteTableViewCell.h"

@implementation RouteTableViewCell

@synthesize headerImg = _headerImg;
@synthesize detailLabel = _detailLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.headerImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 20, 20)];
        [self.contentView addSubview: self.headerImg];
        self.detailLabel = [[UILabel alloc] initWithFrame: CGRectMake(50, 4, [[UIScreen mainScreen] bounds].size.width - 60, 30)];
        [self.contentView addSubview: self.detailLabel];
    }
    
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.headerImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 9, 20, 20)];
        [self.contentView addSubview: self.headerImg];
        self.detailLabel = [[UILabel alloc] initWithFrame: CGRectMake(50, 4, [[UIScreen mainScreen] bounds].size.width - 60, 30)];
        [self.contentView addSubview: self.detailLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
