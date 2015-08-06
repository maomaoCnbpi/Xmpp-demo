//
//  ViewController.m
//  Xmpp demo
//
//  Created by maomao on 15/7/14.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import "ViewController.h"
#import "FriendController.h"
#import "AppDelegate.h"


@interface ViewController ()<XMPPStreamDelegate>

@property (nonatomic, strong) NSString *jidStr;

//@property (nonatomic, strong) XMPPRoom *xmppRoom;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   //  _storage = [[XMPPRoomCoreDataStorage alloc] init];

    
    
    
    
    
}

#pragma mark : my methods
- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

-(BOOL)allInformationReady{
    if (self.NameTextField.text && self.PasswordField.text) {
        [[[self appDelegate] xmppStream] setHostName:HOSTNAME];
        [[[self appDelegate] xmppStream] setHostPort:HOSTPORT];
        [[NSUserDefaults standardUserDefaults]setObject:self.NameTextField.text forKey:kHost];
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@@%@",self.NameTextField.text,PATH] forKey:kMyJID];
        [[NSUserDefaults standardUserDefaults]setObject:self.PasswordField.text forKey:kPS];
        return YES;
    }
    [[self appDelegate] showAlertView:@"信息不完整"];
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//注册
- (IBAction)resignBtn:(id)sender {

    if (![self allInformationReady]) {
        return;
    }
    if ([[[self appDelegate] xmppStream] isConnected] && [[[self appDelegate]xmppStream] supportsInBandRegistration]) {
        NSError *error ;
        [[self appDelegate].xmppStream setMyJID:[XMPPJID jidWithUser:self.NameTextField.text domain:HOSTNAME resource:@"XMPPIOS"]];
        //        [[self appDelegate]setIsRegistration:YES];
        if (![[self appDelegate].xmppStream registerWithPassword:self.PasswordField.text error:&error]) {
            [[self appDelegate] showAlertView:[NSString stringWithFormat:@"%@",error.description]];
        }
    }

   
}

//登陆
- (IBAction)loginBtn:(id)sender {
    
    if ([[self appDelegate].xmppStream isConnected]) {
        if ([[NSUserDefaults standardUserDefaults]objectForKey:kPS]) {
            NSError *error ;
            if (![[self appDelegate].xmppStream authenticateWithPassword:[[NSUserDefaults standardUserDefaults]objectForKey:kPS] error:&error]) {
                NSLog(@"error authenticate : %@",error.description);
            }
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请先链接" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

//连接
- (IBAction)ConnectBtn:(id)sender {
    
    if (![self allInformationReady]) {
        return;
    }
    NSLog(@"连接 - - ");
    //    [[self appDelegate]setIsRegistration:NO];
    [[self appDelegate]myConnect];
}

//获取好友列表
- (IBAction)FriendListBtn:(id)sender {
    
    if ([[self appDelegate].xmppStream isConnected]) {
        
        FriendController *fri = [[FriendController alloc]init];
        [self presentViewController:fri animated:YES completion:nil];

    }else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"请先链接" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alert show];
    }
}

- (IBAction)LoginOutBtn:(id)sender {
     [[self appDelegate].xmppStream disconnectAfterSending];
    NSLog(@" - - -登出 - - -");
}













@end
