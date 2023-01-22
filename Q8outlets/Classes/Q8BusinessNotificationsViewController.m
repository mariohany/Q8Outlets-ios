//
//  Q8BusinessNotificationsViewController.m
//  Q8outlets
//
//  Created by Lesya Verbina on 2/13/17.
//  Copyright © 2017 Lesya Verbina. All rights reserved.
//

#import "Q8BusinessNotificationsViewController.h"
#import "Q8BusinessNotification.h"
#import "Q8BusinessNotificationTableViewCell.h"
#import "Q8DateHeaderTableViewCell.h"
#import "Q8LoadingTableViewCell.h"

@interface Q8BusinessNotificationsViewController ()
@end

@implementation Q8BusinessNotificationsViewController {
    NSMutableArray <Q8BusinessNotification *> *notifications;
    
    NSInteger currentNotificationPage;
    NSInteger notificationTotalCount;
}

enum {
    Q8NotificationRowHeader
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Visual setup
    self.noNotificationsView.hidden = YES;
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //Vegister cell
    UINib *loadingNib = [UINib nibWithNibName:Q8LoadingCellXibName bundle:nil];
    [self.tableView registerNib:loadingNib forCellReuseIdentifier:Q8LoadingCellIdentifier];
    
    notifications = [NSMutableArray array];
    currentNotificationPage = 1;
    
    // Load notifications
    [self loadNotificationsFromServer];
}

#pragma mark - Controller logic

- (void)reloadTableView {
    self.noNotificationsView.hidden = [notifications count];
    [self.tableView reloadData];
}

- (NSArray <NSDate *> *)notificationDates {
    NSMutableArray *dates = [NSMutableArray new];
    for (Q8BusinessNotification *notification in notifications) {
        BOOL duplicate = NO;
        for (NSDate *date in dates) {
            if ([WLUtilityHelper checkIfSameDate:date date2:notification.notificationDate]) {
                duplicate = YES;
                break;
            }
        }
        
        if (!duplicate) {
            [dates addObject:notification.notificationDate];
        }
    }
    return dates;
}

- (NSArray <Q8BusinessNotification *> *)notificationsForDate:(NSDate *)date {
    NSMutableArray *dateNotifications = [NSMutableArray new];
    for (Q8BusinessNotification *notification in notifications) {
        if ([WLUtilityHelper checkIfSameDate:date date2:notification.notificationDate]) {
            [dateNotifications addObject:notification];
        }
    }
    
    dateNotifications = [[WLUtilityHelper arraySorted:dateNotifications byDescriptor:@"notificationDate" ascending:NO] mutableCopy];
    return dateNotifications;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell: (UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > [[self notificationDates] count] - 1) {
        currentNotificationPage++;
        [self loadNotificationsFromServer];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [notifications count] < notificationTotalCount ? [[self notificationDates] count] + 1: [[self notificationDates] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section > [[self notificationDates] count] - 1) {
        return 1;
    } else {
        NSDate *sectionDate = [[self notificationDates] objectAtIndex:section];
        return [[self notificationsForDate:sectionDate] count] ? [[self notificationsForDate:sectionDate] count] + 1 : 0;
    }   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section > [[self notificationDates] count] - 1) {
        Q8LoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8LoadingCellIdentifier forIndexPath:indexPath];
        return cell;
    }
    NSDate *sectionDate = [[self notificationDates] objectAtIndex:indexPath.section];
    if (indexPath.row == Q8NotificationRowHeader) {
        // First row is date header
        Q8DateHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8DateHeaderCellIdentifier];
        [cell setupForDate:sectionDate];
        
        return cell;
    } else {
        Q8BusinessNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Q8BusinessNotificationCellIdentifier];
        
        Q8BusinessNotification *notification = [[self notificationsForDate:sectionDate] objectAtIndex:indexPath.row-1];
        [cell setupForNotification:notification];
        
        return cell;
    }
}

#pragma mark - Server requests

- (void)loadNotificationsFromServer {
    weakify(self);
    [[Q8ServerAPIHelper sharedHelper] getOfferNotification:currentNotificationPage onCompletions:^(BOOL success, NSArray<Q8BusinessNotification *> *notificationArray, NSInteger notificationCount) {
        strongify(self);
        self->notificationTotalCount = notificationCount;
        [self->notifications addObjectsFromArray:notificationArray];
        [self reloadTableView];
    } sender:self];
}

@end
