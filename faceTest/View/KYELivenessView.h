//
//  KYELivenessView.h
//  faceTest
//
//  Created by linxiaobin on 2019/11/26.
//  Copyright © 2019 linxiaobin. All rights reserved.
//

#import "KYEFaceBaseView.h"
#import "LivingConfigModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^SuccessBlock)(NSDictionary *info,UIImage*image);
@interface KYELivenessView : KYEFaceBaseView
-(instancetype)initializeLivenessView:(CGRect)frame config:(LivingConfigModel*)config successBlock:(SuccessBlock)successBlock;
@end

NS_ASSUME_NONNULL_END
