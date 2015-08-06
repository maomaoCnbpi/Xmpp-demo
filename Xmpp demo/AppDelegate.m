//
//  AppDelegate.m
//  Xmpp demo
//
//  Created by maomao on 15/7/14.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import "AppDelegate.h"

#define tag_subcribe_alertView 100




@interface AppDelegate ()<UIAlertViewDelegate>



@end

@implementation AppDelegate

@synthesize xmppStream;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize chatDelegate;
@synthesize xmppReconnect;
@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize xmppMessageArchivingModule;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kMyJID];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kPS];
    
    [self setupStream];
    return YES;
}

-(void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invokltiple times");
    
    //初始化xmppstream
    
    xmppStream = [[XMPPStream alloc]init];
    
#if !TARGRT_IPHONE_SIMULATOR
    {
        //想要xmpp在后台运行 
       
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    //初始化 reconnect
    //这东西可以帮你把意外断开的状态连接回去。。。具体看他的头文件定义
    xmppReconnect = [[XMPPReconnect alloc]init];
    
    //初始化roster
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc]init];
    
#pragma mark: question - - - - - - - - - - - -
    xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    

    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [xmppMessageArchivingModule activate:xmppStream];
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    //激活xmpp的模块
    [xmppReconnect activate:xmppStream];
    [xmppRoster activate:xmppStream];
    
    
        [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
   // [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //下面可以替换成自己的域名和端口
    
    //如果你没有提供一个地址 JID 也是一样可以代替的   jid 的格式类似用户名@域名/roster  ，框架会自动抓取域名作为你的地址
    
    //端口 5322
   // [xmppStream setHostName:HOSTNAME];
  //  [xmppStream setHostPort:HOSTPORT];
    
    //下面这两个根据你自己的配置 需要来设置
   // allowSelfSignedCertificates = NO;
    
}

-(BOOL)myConnect
{
    NSString *jid = [[NSUserDefaults standardUserDefaults]objectForKey:kMyJID];
    NSString *ps = [[NSUserDefaults standardUserDefaults]objectForKey:kPS];
    if (jid == nil || ps == nil) {
        return NO;
    }

    XMPPJID *myjid = [XMPPJID jidWithString:[[NSUserDefaults standardUserDefaults]objectForKey:kMyJID]];
    NSError *error ;
    [xmppStream setMyJID:myjid];
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"连接出错啦  my connected error : %@",error.description);
        return NO;
    }
    return YES;
}

- (void)getExistRoomBlock:(callbackBlock)block
{
    _callbackBlock = block;
    NSXMLElement *queryElement= [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMyJID]];
    [iqElement addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:PATH]]];
    
    [iqElement addAttributeWithName:@"id" stringValue:@"getexistroomid"];
    [iqElement addChild:queryElement];
    [xmppStream sendElement:iqElement];
    
}

- (void)createReservedRoomWithJID:(NSString *)jid
{
    
    NSXMLElement *queryElement= [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[[NSUserDefaults standardUserDefaults]objectForKey:kMyJID]];
    [iqElement addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",jid,[[NSUserDefaults standardUserDefaults]objectForKey:PATH]]];
    [iqElement addAttributeWithName:@"id" stringValue:@"createReservedRoom"];
    [iqElement addChild:queryElement];
    [xmppStream sendElement:iqElement];
    
}
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    //NSLog(@"xmppStreamDidConnect");
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidRegister");
    _isRegistration = YES;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kPS]) {
        NSError *error ;
        if (![self.xmppStream authenticateWithPassword:[[NSUserDefaults standardUserDefaults]objectForKey:kPS] error:&error]) {
            NSLog(@"error authenticate : %@",error.description);
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    [self showAlertView:@"当前用户已经存在,请直接登录"];
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //认证
    NSLog(@" 登陆 -  - xmppStreamDidAuthenticate");
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
    
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"didNotAuthenticate:%@",error.description);
}
- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource
{
   // NSLog(@"alternativeResourceForConflictingResource: %@",conflictingResource);
    return @"XMPPIOS";
}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
  //  NSLog(@"didReceiveIQ: %@",iq.description);
    if (_callbackBlock) {
        _callbackBlock(iq);
        
    }
    return YES;
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    
    if ( [message.body hasPrefix:@"image"]) {
        
        NSLog(@" - -- - -  - 收到图片啦 - - - -");
    }else if ([message.body hasPrefix:@"base64"]){
        NSLog(@" - - - - - - 收到语音啦 - - - -");
    }
    else
    {
        NSLog(@" -  - 您有新消息啦 - - didReceiveMessage: %@",message.description);
    }
    
    if ([self.chatDelegate respondsToSelector:@selector(getNewMessage:Message:)]) {
        [self.chatDelegate getNewMessage:self Message:message];
    }
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
  //  NSLog(@"didReceivePresence: %@",presence.description);
    if (presence.status) {
        if ([self.chatDelegate respondsToSelector:@selector(friendStatusChange:Presence:)]) {
            [self.chatDelegate friendStatusChange:self Presence:presence];
        }
    }
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    NSLog(@"didReceiveError: %@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
  //  NSLog(@"didSendIQ:%@",iq.description);
}
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    if ([message.body hasPrefix:@"image"]) {
        NSLog(@" - - - - 图片已发送 - - -- - - - ");
    }else if([message.body hasPrefix:@"base64"]){
        NSLog(@" - - - - 语音已发送 - - - - - - - ");
    }
    else
    {
        NSLog(@" - - 已发送  - - didSendMessage:%@",message);

    }
   
}
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
   // NSLog(@"didSendPresence:%@",presence.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    NSLog(@"didFailToSendIQ:%@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    NSLog(@"didFailToSendMessage:%@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    NSLog(@"didFailToSendPresence:%@",error.description);
}
- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
   // NSLog(@"xmppStreamWasToldToDisconnect");
}
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"xmppStreamConnectDidTimeout");
}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"xmppStreamDidDisconnect: %@",error.description);
}


#pragma mark - my method
-(void)showAlertView:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    alertView.delegate = self;
    [alertView show];
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == tag_subcribe_alertView && buttonIndex == 1) {
        XMPPJID *jid = [XMPPJID jidWithString:alertView.title];
        [[self xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        //        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:<#(XMPPJID *)#>] ;
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
