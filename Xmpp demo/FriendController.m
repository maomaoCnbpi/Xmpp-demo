//
//  FriendController.m
//  Xmpp demo
//
//  Created by maomao on 15/7/17.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import "FriendController.h"
#import "Model.h"
#import "ChatViewController.h"
#import "XMPPRoster.h"

#define NAVHEIGHT 64


@interface FriendController()<UITableViewDataSource,UITableViewDelegate,XMPPStreamDelegate,UIAlertViewDelegate,XMPPRosterDelegate>
{
    NSMutableArray *_dataArray;//数据源
    UITableView *_tabelView;
    UITextField *text;
    
    
}

@end
@implementation FriendController



-(void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setNav];
    [self creatTableView];
    [self getData];
}

-(void)setNav
{
    //导航条
    UINavigationBar *nav = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, NAVHEIGHT)];
    UINavigationItem * item = [[UINavigationItem alloc]initWithTitle:nil];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(LeftBtn)];
    
    [item setLeftBarButtonItem:leftItem];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(RightBtn)];
    [item setRightBarButtonItem:rightItem];
    
    [self.view addSubview:nav];
    [nav pushNavigationItem:item animated:NO];
    [item setTitle:@"好友列表"];
}

-(void)creatTableView
{
    _dataArray = [[NSMutableArray alloc]init];
    _tabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, NAVHEIGHT, self.view.frame.size.width, self.view.frame.size.height-NAVHEIGHT)style:UITableViewStylePlain];
    _tabelView.backgroundColor = [UIColor clearColor];
    _tabelView.delegate = self;
    _tabelView.dataSource = self;
    _tabelView.tableFooterView = [[UIView alloc]init];
    
    _tabelView.rowHeight = 60;
    
    [self.view addSubview:_tabelView];
    
    
    
}

//左侧点击时间事件
-(void)LeftBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//右侧
-(void)RightBtn
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加好友" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.delegate = self;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    text = [alert textFieldAtIndex:0];
    text.placeholder = @"请输入好友ID";
    text.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [alert show];
}

//添加好友
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@" 添加好友");
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",text.text,PATH]];
        [[[self appDelegate] xmppRoster]subscribePresenceToUser:jid];
        
    }
}


#pragma mark :tableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    //初始化cell并指定其类型，也可自定义cell
    
    UITableViewCell *cell = (UITableViewCell*)[tableView  dequeueReusableCellWithIdentifier:CellIdentifier ];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
  // Configure the cell...
    XMPPUserCoreDataStorageObject *object = [_dataArray objectAtIndex:indexPath.row];
    NSString *name = [object displayName];
    if (!name) {
        name = [object nickname];
    }
    if (!name) {
        name = [object jidStr];
    }
   
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [[[object primaryResource] presence] status];
    cell.tag = indexPath.row;
    return cell;
}



#pragma mark - my method
-(AppDelegate *)appDelegate
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication ]delegate];
    delegate.chatDelegate = self;
    return delegate;
}

//获取好友数据
-(void)getData
{
    NSManagedObjectContext *context = [[[self appDelegate]xmppRosterStorage]mainThreadManagedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    NSError *error;
    NSArray *friends = [context executeFetchRequest:request error:&error];
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:friends];
    //[_tabelView reloadData];
}

#pragma mark - Chat Delegate
-(void)friendStatusChange:(AppDelegate *)appD Presence:(XMPPPresence *)presence
{
    for (XMPPUserCoreDataStorageObject *object in _dataArray) {
        if ([object.jidStr isEqualToString:presence.fromStr] || [object.jidStr isEqualToString:presence.from.bare]) {
            [[[[object primaryResource] presence] childAtIndex:0] setStringValue:presence.status];
        }
    }
    [_tabelView reloadData];
}

-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message
{
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *object = [_dataArray objectAtIndex:indexPath.row];
    NSString *name = [object displayName];
    if (!name) {
        name = [object nickname];
    }
    if (!name) {
        name = [object jidStr];

    }
    
    ChatViewController *chat = [[ChatViewController alloc]init];
    chat.NameLabel = name;
    [self presentViewController:chat animated:YES completion:nil];
}

//-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
//    
//    //取得好友状态
//    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
//    //请求的用户
//    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
//    NSLog(@"presenceType:%@",presenceType);
//    
//    NSLog(@"presence2:%@  sender2:%@",presence,sender);
//    
//    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
//    //接收添加好友请求
//    [[[self appDelegate]xmppRoster ]acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
//}
//接收好友列表
//- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
//{
//    /*
//     <iq>
//     <query>
//     <item jid=""/>
//     <item jid=""/>
//     </query>
//     </iq>
//     */
//    NSXMLElement *query = iq.children[0];
//    for (NSXMLElement *item in query.children) {
//        NSLog(@"%@",item.XMLString);
//       // Model *model = [[Model alloc]init];
//        [_dataArray addObject:item];
//
//    }
//    return YES;
//}

//获取好友列表
//-(void)viewWillAppear:(BOOL)animated
//{
//命名空间 避免命名重复性  OC没有命名空间 所以用前缀来区分
/*
 <iq type="get" id="roster">
 <query xmlns="jabber:iq:roster"/>
 </iq>
 */
//    XMPPIQ *iq = [XMPPIQ iqWithType:@"get"];
//    [iq addAttributeWithName:@"id" stringValue:@"roster"];
//    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:roster"];
//    [iq addChild:query];
//    [_stream sendElement:iq];

//    _dataArray = _List;
//    NSLog(@" - - - %@",_dataArray);
//}







































@end
