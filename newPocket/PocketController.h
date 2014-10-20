//
//  PocketController.h
//  newPocket
//
//  Created by 杜長城 on 8/31/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>

@interface PocketController : ViewController <DBRestClientDelegate>
{
    NSMutableArray *journeyList;
    NSMutableDictionary *passJourney;
    NSMutableDictionary *journeyInfoDict;
    sqlite3 *db;
    DBRestClient *restClient;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
