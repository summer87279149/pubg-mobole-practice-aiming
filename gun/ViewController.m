//
//  ViewController.m
//  gun
//
//  Created by 夏天 on 2018/12/14.
//  Copyright © 2018年 夏天. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#define GUN_WIDTH  10
#define GUN_HEIGHT 10
#define XTRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]
@interface ViewController ()
{
    CFAbsoluteTime start ;
    CFAbsoluteTime end ;
    AVAudioPlayer *player;
}
@property (weak, nonatomic) IBOutlet UIView *toolsView;
@property (weak, nonatomic) IBOutlet UIView *gun;
@property (weak, nonatomic) IBOutlet UIButton *setBtn;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (nonatomic, assign) float lmd;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (weak, nonatomic) IBOutlet UIButton *fireBtn;
@property (nonatomic, strong) NSMutableArray<UIView *> *viewArr;
@property (weak, nonatomic) IBOutlet UILabel *timeConsuming;

@property (weak, nonatomic) IBOutlet UILabel *score;
@property (nonatomic, assign) NSInteger scoreCount;

@end

@implementation ViewController
- (IBAction)fire:(UIButton *)sender {
    [player stop];
    BOOL isHit = NO;
    for (NSInteger i = 0; i<self.viewArr.count; ++i) {
        if(CGRectIntersectsRect(self.viewArr[i].frame, self.gun.frame)){
            [self play];
            [self.viewArr[i] removeFromSuperview];
            [self.viewArr removeObject:self.viewArr[i]];
            isHit = YES;
            self.scoreCount ++;
            self.score.text = [NSString stringWithFormat:@"分数:%ld",(long)self.scoreCount];
            end = CFAbsoluteTimeGetCurrent();
            self.timeConsuming.text = [NSString stringWithFormat:@"耗时:%.1f秒",end -start];
            start = CFAbsoluteTimeGetCurrent();
            return;
        }
    }
    
}
-(void)play{
    [player play];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.width = [[NSString stringWithFormat:@"%f" ,self.view.frame.size.width] intValue];
    self.height = [[NSString stringWithFormat:@"%f" ,self.view.frame.size.height] intValue];
    self.fireBtn.layer.cornerRadius = self.fireBtn.frame.size.width/2;
    
    self.lmd = 1.5;
    self.toolsView.hidden = YES;
    self.scoreCount = 0;
    start = CFAbsoluteTimeGetCurrent();
    [self randomObject];
    [_fireBtn setImage:[UIImage imageNamed:@"timg"] forState:UIControlStateHighlighted];
    
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle]pathForResource:@"Gun.mp3" ofType:nil]];
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
}

-(NSMutableArray*)viewArr{
    if(!_viewArr){
        _viewArr = [NSMutableArray array];
    }
    return _viewArr;
}

-(void)randomObject{
    NSInteger __block tag = 0;
    __weak typeof(self) weakSelf = self;
    NSTimer *timer =   [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        int randomWidthHeight = arc4random() % 30 + 10;
        int randomX =arc4random() % self.width;
        int randomY =arc4random() % self.height;
        CGRect viewFrame = CGRectMake(randomX, randomY, randomWidthHeight, randomWidthHeight);
        if (!CGRectIntersectsRect(viewFrame, self.gun.frame)) {
            UIView *view = [[UIView alloc]initWithFrame:viewFrame];
            view.tag = tag;
            view.layer.cornerRadius = randomWidthHeight/2;
            tag++;
            view.backgroundColor = XTRandomColor;
            [weakSelf.view addSubview:view];
            [weakSelf.viewArr addObject:view];
            [weakSelf.view bringSubviewToFront:self.gun];
        }
    }];
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
    
}
- (IBAction)hideTools:(UIButton *)sender {
    self.setBtn.hidden = NO;
    self.toolsView.hidden = YES;

//    [UIView animateWithDuration:0.4 animations:^{
//        self.toolsView.frame = CGRectMake(0, self.toolsView.frame.origin.y+self.toolsView.frame.size.height, self.toolsView.frame.size.width, self.toolsView.frame.size.height);
//    }];
}

- (IBAction)lmd:(UISlider *)sender {
    self.lmd = sender.value;
    self.text.text = [NSString stringWithFormat:@"%2.f %%",self.lmd*100];
}

- (IBAction)openTools:(UIButton *)sender {
    self.setBtn.hidden = YES;
    self.toolsView.hidden = NO;
//    [UIView animateWithDuration:0.4 animations:^{
//        self.toolsView.frame = CGRectMake(0, self.view.frame.size.height-self.toolsView.frame.size.height, self.toolsView.frame.size.width, self.toolsView.frame.size.height);
//    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    // 获取当前点
    CGPoint curP = [touch locationInView:self.view];
    // 获取上一个点
    CGPoint preP = [touch previousLocationInView:self.view];
    // 获取偏移量
    CGFloat offsetX = curP.x - preP.x;
    CGFloat offsetY = curP.y - preP.y;
    
    // 修改view的位置（frame,center,transform）
    // 每次移动需要和上一次做比较, 所有使用CGAffineTransformTranslate
    self.gun.transform = CGAffineTransformTranslate(self.gun.transform, offsetX*_lmd, offsetY*_lmd);
    //计算边界情况
    if (self.gun.frame.origin.x<0) {
        self.gun.frame = CGRectMake(0, self.gun.frame.origin.y, self.gun.frame.size.width, self.gun.frame.size.height);
    }
    if (self.gun.frame.origin.x>self.view.frame.size.width) {
        self.gun.frame = CGRectMake(self.view.frame.size.width-self.gun.frame.size.width, self.gun.frame.origin.y, self.gun.frame.size.width, self.gun.frame.size.height);
    }
    if (self.gun.frame.origin.y<0) {
        self.gun.frame = CGRectMake(self.gun.frame.origin.x, 0, self.gun.frame.size.width, self.gun.frame.size.height);
    }
    if (self.gun.frame.origin.y>self.view.frame.size.height) {
        self.gun.frame = CGRectMake(self.gun.frame.origin.x, self.view.frame.size.height-self.gun.frame.size.height, self.gun.frame.size.width, self.gun.frame.size.height);
    }

  }


@end
