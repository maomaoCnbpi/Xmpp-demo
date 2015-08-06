//
//  ChartCellFrame.h
//  Xmpp demo
//
//  Created by maomao on 15/7/21.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartMessage.h"

@interface ChartCellFrame : NSObject


@property (nonatomic,assign) CGRect iconRect;
@property (nonatomic,assign) CGRect chartViewRect;
@property (nonatomic,strong) ChartMessage *chartMessage;
@property (nonatomic, assign) CGFloat cellHeight; //cell高度

@end
