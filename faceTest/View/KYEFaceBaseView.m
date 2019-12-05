//
//  KYEFaceBaseView.m
//  faceTest
//
//  Created by linxiaobin on 2019/11/25.
//  Copyright © 2019 linxiaobin. All rights reserved.
//

#import "KYEFaceBaseView.h"

#import <IDLFaceSDK/IDLFaceSDK.h>
#import "VideoCaptureDevice.h"
#import "ImageUtils.h"
#import "RemindView.h"
#import "KYEBrightness.h"

#define scaleValue 0.7
#define ScaleValue 1.0

#define ScreenRect [UIScreen mainScreen].bounds
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface KYEFaceBaseView ()<CaptureDataOutputProtocol>
@property (nonatomic, readwrite, retain) VideoCaptureDevice *videoCapture;
@property (nonatomic, readwrite, retain) UILabel *remindLabel;
@property (nonatomic, readwrite, retain) RemindView * remindView;
@property (nonatomic, readwrite, retain) UILabel * remindDetailLabel;
@property (nonatomic, readwrite, retain) UIImageView * successImage;
@property (nonatomic, strong) UIViewController *rootVC;
@end

@implementation KYEFaceBaseView

- (void)dealloc
{
    self.hasFinished = YES;
    
    self.videoCapture.runningStatus = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setHasFinished:(BOOL)hasFinished {
    _hasFinished = hasFinished;
    if (hasFinished) {
        [self.videoCapture stopSession];
        self.videoCapture.delegate = nil;
    }
}

- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == PoseStatus) {
            [weakSelf.remindLabel setHidden:true];
            [weakSelf.remindView setHidden:false];
            [weakSelf.remindDetailLabel setHidden:false];
            weakSelf.remindDetailLabel.text = warning;
        }else if (status == occlusionStatus) {
            [weakSelf.remindLabel setHidden:false];
            [weakSelf.remindView setHidden:true];
            [weakSelf.remindDetailLabel setHidden:false];
            weakSelf.remindDetailLabel.text = warning;
            weakSelf.remindLabel.text = @"脸部有遮挡";
        }else {
            [weakSelf.remindLabel setHidden:false];
            [weakSelf.remindView setHidden:true];
            [weakSelf.remindDetailLabel setHidden:true];
            weakSelf.remindLabel.text = warning;
        }
    });
}

- (void)singleActionSuccess:(BOOL)success
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            [weakSelf.successImage setHidden:false];
        }else {
            [weakSelf.successImage setHidden:true];
        }
    });
}


-(instancetype)initializeLivenessBaseView:(CGRect)frame config:(nonnull LivingConfigModel *)config{
    if (self == [super initWithFrame:frame]) {
        //记录当前屏幕亮度
        [KYEBrightness saveDefaultBrightness];
        
        [self initConfig:frame config:config];
    }
    return self;
}

#pragma mark - init
-(void)initConfig:(CGRect)frame config:(LivingConfigModel*)config{
    CGFloat KYESCREENW = frame.size.width;
    CGFloat KYESCREENH = frame.size.height;
    
    // 初始化相机处理类
    self.videoCapture = [[VideoCaptureDevice alloc] init];
    self.videoCapture.delegate = self;
    
    if (config.style == KYELivenessViewTypeDefault) {
        // 用于播放视频流
        self.detectRect =  CGRectMake(KYESCREENW*(1-scaleValue)/2.0, KYESCREENH*(1-scaleValue)/2.0, KYESCREENW*scaleValue, KYESCREENH*scaleValue);
        self.displayImageView = [[UIImageView alloc] initWithFrame:self.detectRect];
        self.displayImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.displayImageView];
        
        self.coverImage = [ImageUtils getImageResourceForName:@"facecover"];
        CGRect circleRect = [ImageUtils convertRectFrom:CGRectMake(125, 334, 500, 500) imageSize:self.coverImage.size detectRect:frame];
        self.previewRect = CGRectMake(circleRect.origin.x - circleRect.size.width*(1/scaleValue-1)/2.0, circleRect.origin.y - circleRect.size.height*(1/scaleValue-1)/2.0 - 60, circleRect.size.width/scaleValue, circleRect.size.height/scaleValue);
        
        //画圈
        self.circleView = [[CircleView alloc] initWithFrame:frame];
        self.circleView.circleRect = circleRect;
        [self addSubview:self.circleView];
        
        //successImage
        self.successImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(circleRect)+CGRectGetWidth(circleRect)/2.0-57/2.0, CGRectGetMinY(circleRect)-57/2.0, 57, 57)];
        self.successImage.image = [ImageUtils getImageResourceForName:@"success"];
        [self addSubview:self.successImage];
        [self.successImage setHidden:true];
        
        // 遮罩
        UIImageView* coverImageView = [[UIImageView alloc] initWithFrame:frame];
        coverImageView.image = [ImageUtils getImageResourceForName:@"facecover"];
        coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:coverImageView];
        
        // 关闭
        UIButton* closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[ImageUtils getImageResourceForName:@"close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        closeButton.frame = CGRectMake(20, 30, 30, 30);
        [self addSubview:closeButton];
        
        // 提示框
        self.remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, circleRect.origin.y-70, KYESCREENW, 30)];
        self.remindLabel.textAlignment = NSTextAlignmentCenter;
        self.remindLabel.textColor = OutSideColor;
        self.remindLabel.font = [UIFont boldSystemFontOfSize:22.0];
        [self addSubview:self.remindLabel];
        
        self.remindView = [[RemindView alloc]initWithFrame:CGRectMake((KYESCREENW-200)/2.0, CGRectGetMinY(self.remindLabel.frame), 200, 45)];
        [self addSubview:self.remindView];
        [self.remindView setHidden:YES];
        
        self.remindDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(circleRect)+20, KYESCREENW, 30)];
        self.remindDetailLabel.font = [UIFont systemFontOfSize:20];
        self.remindDetailLabel.textColor = [UIColor whiteColor];
        self.remindDetailLabel.textAlignment = NSTextAlignmentCenter;
        self.remindDetailLabel.text = @"建议略微抬头";
        [self addSubview:self.remindDetailLabel];
        [self.remindDetailLabel setHidden:true];
        
    }else{
         // 用于播放视频流
        self.detectRect = CGRectMake(KYESCREENW*(1-ScaleValue)/2.0, KYESCREENH*(1-ScaleValue)/2.0, KYESCREENW*ScaleValue, KYESCREENH*ScaleValue);
        self.displayImageView = [[UIImageView alloc] initWithFrame:self.detectRect];
        self.displayImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.displayImageView];
        
        self.successImage = [[UIImageView alloc] initWithFrame:CGRectMake((KYESCREENW-57)/2.0, (KYESCREENH-57)/2.0, 57, 57)];
        self.successImage.image = [ImageUtils getImageResourceForName:@"success"];
        [self addSubview:self.successImage];
        [self.successImage setHidden:true];
        
        self.previewRect = self.detectRect;
        
        // 提示框
        self.remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, KYESCREENW, 30)];
        self.remindLabel.textAlignment = NSTextAlignmentCenter;
        self.remindLabel.textColor = [UIColor colorWithRed:246/255.0 green:166/255.0 blue:35/255.0 alpha:1];
        self.remindLabel.font = [UIFont boldSystemFontOfSize:22.0];
        [self addSubview:self.remindLabel];
        
        self.remindView = [[RemindView alloc]initWithFrame:CGRectMake((KYESCREENW-200)/2.0, CGRectGetMinY(self.remindLabel.frame), 200, 45)];
        [self addSubview:self.remindView];
        [self.remindView setHidden:YES];
        
        self.remindDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, KYESCREENH/2 + 20, KYESCREENW, 30)];
        self.remindDetailLabel.font = [UIFont systemFontOfSize:20];
        self.remindDetailLabel.textColor = [UIColor whiteColor];
        self.remindDetailLabel.textAlignment = NSTextAlignmentCenter;
        self.remindDetailLabel.text = @"建议略微抬头";
        [self addSubview:self.remindDetailLabel];
        [self.remindDetailLabel setHidden:true];
    }
    
    // 监听重新返回APP
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignAction) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 设置最小检测人脸阈值
    [[FaceSDKManager sharedInstance] setMinFaceSize:200];
    
    // 设置截取人脸图片大小
    [[FaceSDKManager sharedInstance] setCropFaceSizeWidth:700];
    
    // 设置人脸遮挡阀值
    [[FaceSDKManager sharedInstance] setOccluThreshold:0.5];
    
    // 设置亮度阀值
    [[FaceSDKManager sharedInstance] setIllumThreshold:40];
    
    // 设置图像模糊阀值
    [[FaceSDKManager sharedInstance] setBlurThreshold:0.7];
    
    // 设置头部姿态角度
    [[FaceSDKManager sharedInstance] setEulurAngleThrPitch:10 yaw:10 roll:10];
    
    // 设置是否进行人脸图片质量检测
    [[FaceSDKManager sharedInstance] setIsCheckQuality:YES];
    
    // 设置超时时间
    [[FaceSDKManager sharedInstance] setConditionTimeout:10];
    
    // 设置人脸检测精度阀值
    [[FaceSDKManager sharedInstance] setNotFaceThreshold:0.6];
    
    // 设置照片采集张数
    [[FaceSDKManager sharedInstance] setMaxCropImageNum:1];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _hasFinished = NO;
    self.videoCapture.runningStatus = YES;
    [self.videoCapture startSession];
    //加大屏幕亮度
    [KYEBrightness graduallySetBrightness:0.8];
}

- (void)closeAction {
    _hasFinished = YES;
    self.videoCapture.runningStatus = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [IDLFaceLivenessManager.sharedInstance reset];
        //恢复屏幕之前亮度
        [KYEBrightness fastResumeBrightness];
        
        [self removeFromSuperview];
    }];
}

- (void)faceProcesss:(UIImage *)image{

}

#pragma mark - Notification
- (void)onAppWillResignAction {
    _hasFinished = YES;
}

- (void)onAppBecomeActive {
    _hasFinished = NO;
}

#pragma mark - CaptureDataOutputProtocol
- (void)captureOutputSampleBuffer:(UIImage *)image {
    if (_hasFinished) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.displayImageView.image = image;
    });
    [self faceProcesss:image];
}

- (void)captureError {
    NSString *errorStr = @"出现未知错误，请检查相机设置";
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        errorStr = @"相机权限受限,请在设置中启用";
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:errorStr preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"知道啦" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"知道啦");
        }];
        [alert addAction:action];
        [UIView animateWithDuration:0.1 animations:^{
            [weakSelf closeAction];
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }];
    });
}

@end
