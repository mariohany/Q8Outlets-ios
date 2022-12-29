//
//  Q8Slide.h
//  Q8outlets
//
//  Created by Lesya Verbina on 2/2/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Q8Slide : NSObject

@property (nonatomic, strong) NSString *slideTitle;
@property (nonatomic, strong) NSString *slideText;
@property (nonatomic, strong) NSString *slideImageName;
@property (nonatomic, assign) BOOL isAutorizationPrompt;

@end
