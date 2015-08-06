//
//  KeyBordView.h
//  Xmpp demo
//
//  Created by maomao on 15/7/21.
//  Copyright (c) 2015年 maomao. All rights reserved.
//

#import <UIKit/UIKit.h>


@class KeyBordVIew;

@protocol KeyBordVIewDelegate <NSObject>

-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledReturn:(UITextField *)textFiled;
-(void)KeyBordView:(KeyBordVIew *)keyBoardView textFiledBegin:(UITextField *)textFiled;
-(void)beginRecord;
-(void)finishRecord;
@end




@interface KeyBordVIew : UIView
@property (nonatomic,assign) id<KeyBordVIewDelegate>delegate;


@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) UIButton *voiceBtn;
@property (nonatomic,strong) UIButton *imageBtn;
@property (nonatomic,strong) UIButton *addBtn;
@property (nonatomic,strong) UIButton *speakBtn;
@property (nonatomic,strong) UITextField *textField;


@property (nonatomic,copy) void(^imageClick)();







@end
