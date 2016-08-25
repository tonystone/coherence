//
//  MGMessageLogViewController.m
//  ConnectEditor
//
//  Created by Tony Stone on 7/14/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGMessageLogViewController.h"

@interface MGMessageLogViewController ()
    @property (strong) IBOutlet NSTextView * textView;
@end

@implementation MGMessageLogViewController


    - (instancetype) init {
        return [self initWithNibName:@"MGMessageLogViewController" bundle:nil];
    }

    - (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
        self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
        if (self) {
            [[MGMessageLog instance] registerListener: self];
        }
        return self;
    }

    - (void)appendToTextView:(NSString*)text
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSAttributedString* attr = [[NSAttributedString alloc] initWithString: [text stringByAppendingString: @"\r\n"]];
        
            [[_textView textStorage] appendAttributedString:attr];
            [_textView scrollRangeToVisible:NSMakeRange([[_textView string] length], 0)];
        });
    }

    - (void)didReceiveError:(NSString *)string {
        NSLog(@"%@",string);

        [self appendToTextView: string];
    }

    - (void)didReceiveWarning:(NSString *)string {
        NSLog(@"%@",string);
        
        [self appendToTextView: string];
    }

    - (void)didReceiveInfo:(NSString *)string {
        NSLog(@"%@",string);
        
        [self appendToTextView: string];
    }


@end
