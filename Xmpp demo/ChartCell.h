//
//  ChartCell.h
//  Xmpp demo
//
//  Created by maomao on 15/7/21.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartCellFrame.h"

@class ChartCell;

@protocol ChartCellDelegate <NSObject>

-(void)chartCell:(ChartCell *)chartCell tapContent:(NSString *)content;

@end

@interface ChartCell : UITableViewCell

@property (nonatomic,strong) ChartCellFrame *cellFrame;
@property (nonatomic,assign) id<ChartCellDelegate> delegate;

@end
