//
//  ChatViewController.m
//  Xmpp demo
//
//  Created by maomao on 15/7/21.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import "ChatViewController.h"

#import "NSString+DocumentPath.h"
#import "ChartMessage.h"
#import "ChartCellFrame.h"
#import "ChartCell.h"
#import "KeyBordVIew.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "AFNetworkingUtil.h"

#define NAVHEIGHT 64

@interface ChatViewController()<UITableViewDataSource,UITableViewDelegate,KeyBordVIewDelegate,ChartCellDelegate,AVAudioPlayerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    ChartCellFrame *cellFrame;
    ChartMessage *chartMessage;
    
    XMPPMessage *message;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) KeyBordVIew *keyBordView;
@property (nonatomic,strong) NSMutableArray *cellFrames;
@property (nonatomic,assign) BOOL recording;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) AVAudioRecorder *recorder;
@property (nonatomic,strong) AVAudioPlayer *player;

@property (nonatomic, strong) NSString *toJIDString;
@property (nonatomic, strong) XMPPJID *toJID;
@property (copy, nonatomic) NSString *originWav;

@end
static NSString *const cellIdentifier=@"Chart";

@implementation ChatViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cellFrame=[[ChartCellFrame alloc]init];
    chartMessage=[[ChartMessage alloc]init];
    self.view.backgroundColor=[UIColor whiteColor];
    
    //add UItableView
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.bounds.size.height-64-44) style:UITableViewStylePlain];
    [self.tableView registerClass:[ChartCell class] forCellReuseIdentifier:cellIdentifier];
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg_default.jpg"]];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    
    //add keyBorad
    
    self.keyBordView=[[KeyBordVIew alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height- 44, self.view.frame.size.width, 44)];
    self.keyBordView.delegate=self;
    [self.view addSubview:self.keyBordView];
    
    //添加回调
    ChatViewController *_self = self;
    [self.keyBordView setImageClick:^{
        
        [_self addImage];
    
    }];
    
    //初始化数据
        dataArray = [[NSMutableArray alloc]init];
   
    _toJID = [XMPPJID jidWithString:_NameLabel];
    _toJIDString = self.xmppUserObject.jidStr;
    [self getMessageData];

    
    [self initwithData];
    [self setNav];
    
    //send
    message = [XMPPMessage messageWithType:@"chat" to:self.toJID];
}

#pragma mark : addImage
-(void)addImage
{
     NSLog(@"添加图片");
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [picker setAllowsEditing:NO];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSData *data = UIImagePNGRepresentation(image);
    
   
    [self dismissViewControllerAnimated:YES completion:nil];
    
     [self sendMessageWithData:data bodyName:@"image"];
}

/** 发送二进制文件 */
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name
{
   // XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_toJID];
    
    [message addBody:name];
    
    // 转换成base64的编码
    NSString *base64str = [data base64EncodedStringWithOptions:0];
    
       // 设置节点内容
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];
    
       // 包含子节点
    [message addChild:attachment];
    
      // 发送消息
    [[self appDelegate].xmppStream sendElement:message];
}
-(void)setNav
{
    //导航条
    UINavigationBar *nav = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, NAVHEIGHT)];
    UINavigationItem * item = [[UINavigationItem alloc]initWithTitle:nil];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(LeftBtn)];
    
    [item setLeftBarButtonItem:leftItem];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(RightBtn)];
    [item setRightBarButtonItem:rightItem];
    
    [self.view addSubview:nav];
    [nav pushNavigationItem:item animated:NO];
    [item setTitle:_NameLabel];
    
    }


- (void)getMessageData{
    NSManagedObjectContext *context = [[self appDelegate].xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error ;
    NSArray *messages = [context executeFetchRequest:request error:&error];
    
    //
    [dataArray removeAllObjects];
    [dataArray addObjectsFromArray:messages];
    
    
}

- (void)sendMessage{
    
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body" stringValue:self.keyBordView.textField.text];
    
    [message addChild:body];
    [[[self appDelegate] xmppStream] sendElement:message];
}


#pragma mark - my method
-(AppDelegate *)appDelegate
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication ]delegate];
    delegate.chatDelegate = self;
    return delegate;
    
}

//返回
-(void)LeftBtn
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)RightBtn
{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"是否删除当前好友" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.delegate = self;
   
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSLog(@"删除好友");
        XMPPJID *jid = [XMPPJID jidWithString:_NameLabel];
        [[[self appDelegate]xmppRoster]removeUser:jid];
    }
}
-(void)initwithData
{
    
    self.cellFrames=[NSMutableArray array];
    
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellFrames.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChartCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate=self;
    cell.cellFrame=self.cellFrames[indexPath.row];
    
    //
    XMPPMessageArchiving_Message_CoreDataObject *object = [dataArray objectAtIndex:indexPath.row];
    NSMutableString *showString = [[NSMutableString alloc] init];

    if (object.body){
        [showString appendFormat:@"body:%@\n",object.body];
    }

    
    
    
    
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cellFrames[indexPath.row] cellHeight];
}
-(void)chartCell:(ChartCell *)chartCell tapContent:(NSString *)content
{
    if(self.player.isPlaying){
        
        [self.player stop];
    }
    //播放
    NSString *filePath=[NSString documentPathWith:content];
    
    NSURL *fileUrl=[NSURL fileURLWithPath:filePath];
    [self initPlayer];
    NSError *error;
    self.player=[[AVAudioPlayer alloc]initWithContentsOfURL:fileUrl error:&error];
    [self.player setVolume:1];
    [self.player prepareToPlay];
    [self.player setDelegate:self];
    [self.player play];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[UIDevice currentDevice]setProximityMonitoringEnabled:NO];
    [self.player stop];
    self.player=nil;
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    [self.view endEditing:YES];
}

//delegate
-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledReturn:(UITextField *)textFiled
{
    
    
    chartMessage.icon=@"icon02.jpg";
    chartMessage.messageType=1;
    chartMessage.content=textFiled.text;
    cellFrame.chartMessage=chartMessage;
    
    [self.cellFrames addObject:cellFrame];
    [self.tableView reloadData];

    if (textFiled.text != nil) {
        [self sendMessage];
    }
    //滚动到当前行
    
    
    [self tableViewScrollCurrentIndexPath];
    textFiled.text=@"";
    
}
-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledBegin:(UITextField *)textFiled
{
    [self tableViewScrollCurrentIndexPath];
    
}
-(void)beginRecord
{
    if(self.recording)return;
    
    self.recording=YES;
    
    NSDictionary *settings=[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithFloat:8000],AVSampleRateKey,
                            [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                            [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                            [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                            [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                            nil];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyyMMddHHmmss"];
    NSString *fileName = [NSString stringWithFormat:@"rec_%@.wav",[dateFormater stringFromDate:now]];
    self.fileName=fileName;
    NSString *filePath=[NSString documentPathWith:fileName];
   // NSLog(@" - - -%@",filePath);
    NSURL *fileUrl=[NSURL fileURLWithPath:filePath];
    NSError *error;
    self.recorder=[[AVAudioRecorder alloc]initWithURL:fileUrl settings:settings error:&error];
    [self.recorder prepareToRecord];
    [self.recorder setMeteringEnabled:YES];
    [self.recorder peakPowerForChannel:0];
    [self.recorder record];
    
}
-(void)sendVoice
{
   NSString *filePath = [NSString documentPathWith:_fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *base64 = [data base64EncodedString];
    [self sendAudio:base64 withName:_fileName];
    
}
-(void)sendAudio:(NSString *)base64String withName:(NSString *)audioName{
    NSMutableString *soundString = [[NSMutableString alloc]initWithString:@"base64"];
    [soundString appendString:base64String];
   
    [message addBody:soundString];
    
    
    [[[self appDelegate] xmppStream] sendElement:message];
}
-(void)finishRecord
{
    self.recording=NO;
    [self.recorder stop];
    self.recorder=nil;
    //fasong
    [self sendVoice];
    
    chartMessage.icon=@"icon02.jpg";
    chartMessage.messageType=1;
    chartMessage.content=self.fileName;
    cellFrame.chartMessage=chartMessage;
    [self.cellFrames addObject:cellFrame];
    [self.tableView reloadData];
    [self tableViewScrollCurrentIndexPath];
    
}
-(void)tableViewScrollCurrentIndexPath
{
    if (self.cellFrames.count != 0) {
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:self.cellFrames.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    }
}
-(void)initPlayer{
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    audioSession = nil;
}

#pragma mark - ChatDelegate
-(void)getNewMessage:(AppDelegate *)appD Message:(XMPPMessage *)message
{
    
    [self getMessageData];
    
    
    chartMessage.icon=@"icon01.jpg";
    chartMessage.messageType=0;
    chartMessage.content=message.body;
    cellFrame.chartMessage=chartMessage;
    
    [self.cellFrames addObject:cellFrame];
    [self.tableView reloadData];
    
    

    //滚动到当前行
    
    [self tableViewScrollCurrentIndexPath];
    
    

    
    [self.tableView reloadData];
}
-(void)friendStatusChange:(AppDelegate *)appD Presence:(XMPPPresence *)presence
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

