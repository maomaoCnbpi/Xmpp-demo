//
//  ViewController.h
//  Xmpp demo
//
//  Created by maomao on 15/7/14.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *NameTextField;
@property (weak, nonatomic) IBOutlet UITextField *PasswordField;
- (IBAction)resignBtn:(id)sender;

- (IBAction)loginBtn:(id)sender;
- (IBAction)ConnectBtn:(id)sender;
- (IBAction)FriendListBtn:(id)sender;
- (IBAction)LoginOutBtn:(id)sender;

@end

