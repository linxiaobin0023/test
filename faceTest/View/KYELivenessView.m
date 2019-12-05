//
//  KYELivenessView.m
//  faceTest
//
//  Created by linxiaobin on 2019/11/26.
//  Copyright © 2019 linxiaobin. All rights reserved.
//

#import "KYELivenessView.h"
#import <IDLFaceSDK/IDLFaceSDK.h>
#import "KYEBrightness.h"

@interface KYELivenessView ()
@property (nonatomic, strong) NSArray * livenessArray;
@property (nonatomic, assign) BOOL order;
@property (nonatomic, assign) NSInteger numberOfLiveness;
@end

@implementation KYELivenessView{
    LivingConfigModel *_config;
    SuccessBlock _successBlock;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [[IDLFaceLivenessManager sharedInstance] startInitial];
}


-(instancetype)initializeLivenessView:(CGRect)frame config:(LivingConfigModel*)config successBlock:(SuccessBlock)successBlock{
    if (self == [super initializeLivenessBaseView:frame config:config]) {
        _config = config;
        _successBlock = successBlock;
        [self livenesswithList:config.liveActionArray order:config.isByOrder numberOfLiveness:config.numOfLiveness];
    }
    return self;
}

- (void)onAppBecomeActive {
    [super onAppBecomeActive];
    [[IDLFaceLivenessManager sharedInstance] livenesswithList:_livenessArray order:_order numberOfLiveness:_numberOfLiveness];
}

- (void)onAppWillResignAction {
    [super onAppWillResignAction];
    [IDLFaceLivenessManager.sharedInstance reset];
}

- (void)livenesswithList:(NSArray *)livenessArray order:(BOOL)order numberOfLiveness:(NSInteger)numberOfLiveness {
    _livenessArray = [NSArray arrayWithArray:livenessArray];
    _order = order;
    _numberOfLiveness = numberOfLiveness;
    [[IDLFaceLivenessManager sharedInstance] livenesswithList:livenessArray order:order numberOfLiveness:numberOfLiveness];
}

- (void)faceProcesss:(UIImage *)image {
    if (self.hasFinished) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[IDLFaceLivenessManager sharedInstance] livenessStratrgyWithImage:image previewRect:self.previewRect detectRect:self.detectRect completionHandler:^(NSDictionary *images, LivenessRemindCode remindCode) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        UIImage *image;
        [data setValue:@(remindCode).description forKey:@"remindCode"];

        switch (remindCode) {
            case LivenessRemindCodeOK: {
                weakSelf.hasFinished = YES;
                [self warningStatus:CommonStatus warning:@"非常好"];
                if (images[@"bestImage"] != nil && [images[@"bestImage"] count] != 0) {
                    
                    NSData* data = [[NSData alloc] initWithBase64EncodedString:[images[@"bestImage"] lastObject] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage* bestImage = [UIImage imageWithData:data];
                    NSLog(@"bestImage = %@",bestImage);
                    image = bestImage;
                }
                if (images[@"liveEye"] != nil) {
                    NSData* data = [[NSData alloc] initWithBase64EncodedString:images[@"liveEye"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage* liveEye = [UIImage imageWithData:data];
                    NSLog(@"liveEye = %@",liveEye);
                    image = liveEye;
                }
                if (images[@"liveMouth"] != nil) {
                    NSData* data = [[NSData alloc] initWithBase64EncodedString:images[@"liveMouth"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage* liveMouth = [UIImage imageWithData:data];
                    NSLog(@"liveMouth = %@",liveMouth);
                    image = liveMouth;
                }
                if (images[@"yawRight"] != nil) {
                    NSData* data = [[NSData alloc] initWithBase64EncodedString:images[@"yawRight"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage* yawRight = [UIImage imageWithData:data];
                    NSLog(@"yawRight = %@",yawRight);
                    image = yawRight;
                }
                if (images[@"yawLeft"] != nil) {
                    NSData* data = [[NSData alloc] initWithBase64EncodedString:images[@"yawLeft"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage* yawLeft = [UIImage imageWithData:data];
                    NSLog(@"yawLeft = %@",yawLeft);
                    image = yawLeft;
                }
                if (images[@"pitchUp"] != nil) {
                    NSData* data = [[NSData alloc] initWithBase64EncodedString:images[@"pitchUp"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage* pitchUp = [UIImage imageWithData:data];
                    NSLog(@"pitchUp = %@",pitchUp);
                    image = pitchUp;
                }
                if (images[@"pitchDown"] != nil) {
                    NSData* data = [[NSData alloc] initWithBase64EncodedString:images[@"pitchDown"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    UIImage* pitchDown = [UIImage imageWithData:data];
                    NSLog(@"pitchDown = %@",pitchDown);
                    image = pitchDown;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf closeAction];
                    //恢复屏幕亮度
                    [KYEBrightness fastResumeBrightness];
                });
                if (self->_config.style == KYELivenessViewTypeDefault) {
                    self.circleView.conditionStatusFit = true;
                }
                [self singleActionSuccess:true];
                [data setValue:@"非常好" forKey:@"warningStr"];
                break;
            }
            case LivenessRemindCodePitchOutofDownRange:
                [self warningStatus:PoseStatus warning:@"建议略微抬头" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"建议略微抬头" forKey:@"warningStr"];
                break;
            case LivenessRemindCodePitchOutofUpRange:
                [self warningStatus:PoseStatus warning:@"建议略微低头" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"建议略微低头" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeYawOutofLeftRange:
                [self warningStatus:PoseStatus warning:@"建议略微向右转头" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"建议略微向右转头" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeYawOutofRightRange:
                [self warningStatus:PoseStatus warning:@"建议略微向左转头" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"建议略微向左转头" forKey:@"warningStr"];
                break;
            case LivenessRemindCodePoorIllumination:
                [self warningStatus:CommonStatus warning:@"光线再亮些" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"光线再亮些" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeNoFaceDetected:
                [self warningStatus:CommonStatus warning:@"把脸移入框内" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"把脸移入框内" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeImageBlured:
                [self warningStatus:CommonStatus warning:@"请保持不动" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"请保持不动" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeOcclusionLeftEye:
                [self warningStatus:occlusionStatus warning:@"左眼有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"左眼有遮挡" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeOcclusionRightEye:
                [self warningStatus:occlusionStatus warning:@"右眼有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"右眼有遮挡" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeOcclusionNose:
                [self warningStatus:occlusionStatus warning:@"鼻子有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"鼻子有遮挡" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeOcclusionMouth:
                [self warningStatus:occlusionStatus warning:@"嘴巴有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"嘴巴有遮挡" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeOcclusionLeftContour:
                [self warningStatus:occlusionStatus warning:@"左脸颊有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"左脸颊有遮挡" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeOcclusionRightContour:
                [self warningStatus:occlusionStatus warning:@"右脸颊有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"右脸颊有遮挡" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeOcclusionChinCoutour:
                [self warningStatus:occlusionStatus warning:@"下颚有遮挡" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"下颚有遮挡" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeTooClose:
                [self warningStatus:CommonStatus warning:@"手机拿远一点" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"手机拿远一点" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeTooFar:
                [self warningStatus:CommonStatus warning:@"手机拿近一点" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"手机拿近一点" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeBeyondPreviewFrame:
                [self warningStatus:CommonStatus warning:@"把脸移入框内" conditionMeet:false];
                [self singleActionSuccess:false];
                [data setValue:@"把脸移入框内" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeLiveEye:
                [self warningStatus:CommonStatus warning:@"眨眨眼" conditionMeet:true];
                [self singleActionSuccess:false];
                [data setValue:@"眨眨眼" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeLiveMouth:
                [self warningStatus:CommonStatus warning:@"张张嘴" conditionMeet:true];
                [self singleActionSuccess:false];
                [data setValue:@"张张嘴" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeLiveYawRight:
                [self warningStatus:CommonStatus warning:@"向右缓慢转头" conditionMeet:true];
                [self singleActionSuccess:false];
                [data setValue:@"向右缓慢转头" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeLiveYawLeft:
                [self warningStatus:CommonStatus warning:@"向左缓慢转头" conditionMeet:true];
                [self singleActionSuccess:false];
                [data setValue:@"向左缓慢转头" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeLivePitchUp:
                [self warningStatus:CommonStatus warning:@"缓慢抬头" conditionMeet:true];
                [self singleActionSuccess:false];
                [data setValue:@"缓慢抬头" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeLivePitchDown:
                [self warningStatus:CommonStatus warning:@"缓慢低头" conditionMeet:true];
                [self singleActionSuccess:false];
                [data setValue:@"缓慢低头" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeLiveYaw:
                [self warningStatus:CommonStatus warning:@"摇摇头" conditionMeet:true];
                [self singleActionSuccess:false];
                [data setValue:@"摇摇头" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeSingleLivenessFinished:
            {
                [self warningStatus:CommonStatus warning:@"非常好" conditionMeet:true];
                [self singleActionSuccess:true];
                [data setValue:@"非常好" forKey:@"warningStr"];
            }
                break;
            case LivenessRemindCodeVerifyInitError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                [data setValue:@"验证失败" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeVerifyDecryptError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                [data setValue:@"验证失败" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeVerifyInfoFormatError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                [data setValue:@"验证失败" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeVerifyExpired:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                [data setValue:@"验证失败" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeVerifyMissRequiredInfo:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                [data setValue:@"验证失败" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeVerifyInfoCheckError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                [data setValue:@"验证失败" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeVerifyLocalFileError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                [data setValue:@"验证失败" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeVerifyRemoteDataError:
                [self warningStatus:CommonStatus warning:@"验证失败"];
                [data setValue:@"验证失败" forKey:@"warningStr"];
                break;
            case LivenessRemindCodeTimeout: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.1 animations:^{
                        [weakSelf closeAction];
                    } completion:^(BOOL finished) {
                        [data setValue:@"超时" forKey:@"warningStr"];
                    }];
                });
                break;
            }
            case LivenessRemindCodeConditionMeet: {
                if (self->_config.style == KYELivenessViewTypeDefault) {
                    self.circleView.conditionStatusFit = true;
                }
            }
                break;
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->_successBlock) {
                self->_successBlock(data,image);
            }
        });
    }];
}

- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning conditionMeet:(BOOL)meet
{
    [self warningStatus:status warning:warning];
    if (_config == KYELivenessViewTypeDefault) {
        self.circleView.conditionStatusFit = meet;
    }
}

@end
