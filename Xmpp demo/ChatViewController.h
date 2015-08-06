//
//  ChatViewController.h
//  Xmpp demo
//
//  Created by maomao on 15/7/21.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface ChatViewController : UIViewController<ChatDelegate>
{
    NSMutableArray  *dataArray;
}
@property (nonatomic,strong)NSString *NameLabel;

@property (nonatomic,strong) XMPPUserCoreDataStorageObject *xmppUserObject;

-(void)sendMessage;



@end
