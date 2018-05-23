//
//  RootViewController.m
//  Coherence Example
//
//  Created by Tony Stone on 5/22/18.
//  Copyright © 2018 Tony Stone. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()
    
@end

@implementation RootViewController

@synthesize connect;

- (void)viewDidLoad {
    [super viewDidLoad];

    NSManagedObjectContext * context = [connect viewContext];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
