//
//  KYEFaceBaseView.h
//  faceTest
//
//  Created by linxiaobin on 2019/11/25.
//  Copyright © 2019 linxiaobin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LivingConfigModel.h"
#import "CircleView.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    CommonStatus,
    PoseStatus,
    occlusionStatus
} WarningStatus;

@interface KYEFaceBaseView : UIView
@property (nonatomic, readwrite, retain) UIImageView *displayImageView;
@property (nonatomic, readwrite, assign) BOOL hasFinished;
@property (nonatomic, readwrite, retain) UIImage* coverImage;
@property (nonatomic, readwrite, assign) CGRect previewRect;
@property (nonatomic, readwrite, assign) CGRect detectRect;
@property (nonatomic, readwrite, retain) CircleView * circleView;

- (void)faceProcesss:(UIImage *)image;
- (void)closeAction;
- (void)onAppWillResignAction;
- (void)onAppBecomeActive;
- (void)warningStatus:(WarningStatus)status warning:(NSString *)warning;
- (void)singleActionSuccess:(BOOL)success;
-(instancetype)initializeLivenessBaseView:(CGRect)frame config:(LivingConfigModel*)config;
@end

NS_ASSUME_NONNULL_END
