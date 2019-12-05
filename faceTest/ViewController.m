//
//  ViewController.m
//  faceTest
//
//  Created by linxiaobin on 2019/11/25.
//  Copyright © 2019 linxiaobin. All rights reserved.
//

#import "ViewController.h"
#import <IDLFaceSDK/IDLFaceSDK.h>
#import "KYELivenessView.h"
#import "LivingConfigModel.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *captureView;
@property (nonatomic,strong) KYELivenessView *liveNessView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)captureData:(id)sender {
    
    LivingConfigModel *model = [LivingConfigModel sharedInstance];
    [model.liveActionArray addObject:@(FaceLivenessActionTypeLiveEye)];
    model.numOfLiveness = 1;
    model.isByOrder = YES;
    model.style     = KYELivenessViewTypeCustom;
    model.frame     = CGRectMake(0, 0, self.captureView.frame.size.width, self.captureView.frame.size.height);
    
//    __weak typeof(self) wealSelf = self;
    self.liveNessView = [[KYELivenessView alloc] initializeLivenessView:model.frame config:model successBlock:^(NSDictionary *info,UIImage*image) {
        NSLog(@"%@--%@",info,image);
    }];
    [self.captureView addSubview:self.liveNessView];
}

- (IBAction)closeCaptureData:(id)sender {
    [self.liveNessView closeAction];
}

@end
