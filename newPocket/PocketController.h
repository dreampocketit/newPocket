//
//  PocketController.h
//  newPocket
//
//  Created by 杜長城 on 8/31/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface PocketController : ViewController
{
    NSMutableArray *journeyList;
    NSMutableDictionary *passJourney;
    NSMutableDictionary *journeyInfoDict;
    sqlite3 *db;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
