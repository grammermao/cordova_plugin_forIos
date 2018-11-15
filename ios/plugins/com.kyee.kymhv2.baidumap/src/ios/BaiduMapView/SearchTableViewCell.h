//
//  SearchTableViewCell.h
//  Route
//
//  Created by Zhu Xueliang on 15/6/19.
//  Copyright (c) 2015年 Zhu Xueliang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell {
    UIImageView *_headerImg;
    UILabel *_hospitalName;
    UILabel *_hospitalAddr;
}

@property (nonatomic, strong) UIImageView *headerImg;
@property (nonatomic, strong) UILabel *hospitalName;
@property (nonatomic, strong) UILabel *hospitalAddr;
@end
