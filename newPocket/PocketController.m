//
//  PocketController.m
//  newPocket
//
//  Created by 杜長城 on 8/31/14.
//  Copyright (c) 2014 杜長城. All rights reserved.
//

#import "PocketController.h"
#import "JourneyController.h"

@interface PocketController ()

@end

@implementation PocketController
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //initial a notification for reload tableview function
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ReloadJourneyFunction:)
                                                 name:@"refreshJourney"
                                               object:nil];

    
    journeyList = [[NSMutableArray alloc] init]; //List all journey on Pocket page
    
    // get the newest journey list
    [self loadJourneyFromDB];
    
    
    // if there is a journey onGoing, directly redirect to the journey
    for(NSMutableDictionary *journey in journeyList) {
        NSString *onGoing = [journey objectForKey:@"traveling"];
        if ([onGoing isEqualToString:@"1"]) {
            NSLog([journey objectForKey:@"name"]);
            passJourney = [[NSMutableDictionary alloc] init];
            [passJourney setObject:[journey objectForKey:@"name"] forKey:@"name"];
            [passJourney setObject:onGoing forKey:@"onGoing"];
            [passJourney setObject:[journey objectForKey:@"iid"] forKey:@"iid"];
            [self performSegueWithIdentifier:@"showJourney" sender:self];
            break;
        }
    }
     
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [journeyList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indicator = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indicator];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indicator];
    }
    cell.textLabel.text = [[journeyList objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //to compare two value, we must transform the value into NSInteger first for condition of IF works normally
    NSNumber *traveling = [[journeyList objectAtIndex:indexPath.row] objectForKey:@"traveling"];
    NSInteger travelingCheck = [traveling integerValue];
    
    NSNumber *yes = [NSNumber numberWithInteger:1];
    NSInteger yesCheck = [yes integerValue];
    
    
    passJourney = [[NSMutableDictionary alloc] init];
    
    
    // to get if the journey is on going, and pass variable to next controller
    if (indexPath.row > -1)
	{
        NSLog(@"PocketController: check the journeyState");
        // check if user is on journey
        if (travelingCheck==yesCheck) {
            NSString *state = @"1";
            //NSLog(@"yes");
            [passJourney setObject:[[journeyList objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"name"];
            [passJourney setObject:state forKey:@"onGoing"];
            [passJourney setObject:[[journeyList objectAtIndex:indexPath.row] objectForKey:@"iid"] forKey:@"iid"];
        } else{
            //NSLog(@"no");
            NSString *state = @"0";
            [passJourney setObject:[[journeyList objectAtIndex:indexPath.row] objectForKey:@"name"] forKey:@"name"];
            [passJourney setObject:state forKey:@"onGoing"];
            [passJourney setObject:[[journeyList objectAtIndex:indexPath.row] objectForKey:@"iid"] forKey:@"iid"];
        }
    }
    [self performSegueWithIdentifier:@"showJourney" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"PocketController: do the segue");
    //addToCartViewContollerForItem
    if([[segue identifier] isEqualToString:@"showJourney"]){
        NSIndexPath *selectedRow = [[self tableView] indexPathForSelectedRow];
        
        
        JourneyController *vc = [segue destinationViewController];
        [vc setJourneyState:passJourney];
    }
    
    
}

// implement a reload tableview function
-(void)ReloadJourneyFunction:(NSNotification *)notification {
    
    [self loadJourneyFromDB];
    
    NSLog(@"PocketController: reload");
    // 用迴圈取得位於ViewController上的每一個UIView類別
    for (UIView *view in self.view.subviews) {
        // 判斷取得的view是否屬於UITableView類別
        if ([view isKindOfClass:[UITableView class]]) {
            // 如果是就強制轉型為UITableView
            UITableView *tableView = (UITableView *)view;
            // 要求重新載入資料
            [tableView reloadData];
            break;
        }
    }
    
}

-(void) loadJourneyFromDB {
    // 取得已開啓的資料庫連線變數
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    db = [delegate getDB];
    
    if (db != nil) {
        // 準備好查詢的SQL command
        const char *sql = "SELECT * FROM journeys";
        // statement用來儲存執行結果
        sqlite3_stmt *statement;
        sqlite3_prepare(db, sql, -1, &statement, NULL);
        [journeyList removeAllObjects];
        
        // 利用迴圈取出查詢結果
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *iid = (char *)sqlite3_column_text(statement, 0);
            char *name = (char *)sqlite3_column_text(statement, 1);
            char *country = (char *)sqlite3_column_text(statement, 2);
            char *city = (char *)sqlite3_column_text(statement, 3);
            char *start = (char *)sqlite3_column_text(statement, 4);
            char *end = (char *)sqlite3_column_text(statement, 5);
            char *description = (char *)sqlite3_column_text(statement, 6);
            char *profilepic = (char *)sqlite3_column_text(statement, 7);
            char *traveling = (char *)sqlite3_column_text(statement, 8);
            
            journeyInfoDict = [[NSMutableDictionary alloc] init];
            [journeyInfoDict setObject:[NSString stringWithFormat:@"%s", iid, nil] forKey:@"iid"];
            [journeyInfoDict setObject:[NSString stringWithFormat:@"%s", name, nil] forKey:@"name"];
            [journeyInfoDict setObject:[NSString stringWithFormat:@"%s", country, nil] forKey:@"country"];
            [journeyInfoDict setObject:[NSString stringWithFormat:@"%s", city, nil] forKey:@"city"];
            [journeyInfoDict setObject:[NSString stringWithFormat:@"%s", start, nil] forKey:@"start"];
            [journeyInfoDict setObject:[NSString stringWithFormat:@"%s", end, nil] forKey:@"end"];
            [journeyInfoDict setObject:[NSString stringWithFormat:@"%s", description, nil] forKey:@"description"];
            [journeyInfoDict setObject:[NSString stringWithFormat:@"%s", profilepic, nil] forKey:@"profilepic"];
            [journeyInfoDict setObject:[NSString stringWithFormat:@"%s", traveling, nil] forKey:@"traveling"];
            
            /*
            NSString *asd = [NSString stringWithFormat:@"%s", traveling, nil];
            if ([asd isEqualToString:@"1"]) {
                NSLog(@"the journey is on");
            }
            */
            
            // for test sqlite connection
            /*
             NSLog([journeyInfoDict objectForKey:@"iid"]);
             NSLog([journeyInfoDict objectForKey:@"name"]);
             NSLog([journeyInfoDict objectForKey:@"country"]);
             NSLog([journeyInfoDict objectForKey:@"city"]);
             NSLog([journeyInfoDict objectForKey:@"start"]);
             NSLog([journeyInfoDict objectForKey:@"end"]);
             NSLog([journeyInfoDict objectForKey:@"description"]);
             NSLog([journeyInfoDict objectForKey:@"profilepic"]);
             NSLog([journeyInfoDict objectForKey:@"traveling"]);
             */
            
            [journeyList addObject:journeyInfoDict];
        }
        
        sqlite3_finalize(statement);
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
