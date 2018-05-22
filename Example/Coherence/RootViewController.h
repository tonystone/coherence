//
//  RootViewController.h
//  Coherence Example
//
//  Created by Tony Stone on 5/22/18.
//  Copyright © 2018 Tony Stone. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Coherence;

@interface RootViewController : UIViewController
    @property (nonatomic, strong) id <Connect> connect;
@end
