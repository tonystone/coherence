//
//  ViewController.m
//  Connect Example App
//
//  Created by Tony Stone on 10/21/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "ViewController.h"
#import "MGConnect.h"

@interface ViewController ()
- (IBAction) executeFetch:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)executeFetch:(id)sender {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    NSManagedObjectContext * context = [[MGConnect sharedManager] mainThreadManagedObjectContext];
    NSEntityDescription    * entity  = [NSEntityDescription entityForName: @"Region" inManagedObjectContext: context];
    
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity: entity];
    [fetchRequest setPredicate: [NSPredicate predicateWithValue: TRUE]];
    
    NSError * error = nil;
    
    if (![context executeFetchRequest: fetchRequest error: &error]) {
        NSLog(@"Fetch Error: %@", error);
    }
}

@end
