//
//  UIViewController+APPViewRequest.m
//  imiss-ios-master
//
//  Created by 郑业强 on 2018/10/27.
//  Copyright © 2018年 kk. All rights reserved.
//

#import "UIViewController+APPViewRequest.h"

@implementation UIViewController (APPViewRequest)


- (void)setAfn_request:(APPViewRequest *)afn_request {
    [self.view setAfn_request:afn_request];
}
- (APPViewRequest *)afn_request {
    return [self.view afn_request];
}


@end