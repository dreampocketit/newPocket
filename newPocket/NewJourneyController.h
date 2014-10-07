//
//  NewJourneyController.h
//  newPocket
//
//  Created by 杜長城 on 9/1/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface NewJourneyController : ViewController
{
    NSMutableDictionary *journeyDetail;// for saving data from user entered about journey
}

@property (weak, nonatomic) IBOutlet UITextField *journeyNameField;
@property (weak, nonatomic) IBOutlet UITextField *JourneyLocationField;

@end
