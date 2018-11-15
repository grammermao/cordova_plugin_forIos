//
//  RouteTableViewCell.h
//  Route
//
//  Created by Zhu Xueliang on 15/6/19.
//  Copyright (c) 2015年 Zhu Xueliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteTableViewCell : UITableViewCell {
    UIImageView *_headerImg;
    UILabel *_detailLabel;
}

@property (nonatomic, strong) UIImageView *headerImg;
@property (nonatomic, strong) UILabel *detailLabel;

@end
