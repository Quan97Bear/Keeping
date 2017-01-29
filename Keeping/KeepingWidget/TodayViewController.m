//
//  TodayViewController.m
//  KeepingWidget
//
//  Created by 宋 奎熹 on 2017/1/29.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "Task.h"
#import "DateUtil.h"
#import "Utilities.h"
#import "KPWidgetTableViewCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "TaskManager.h"

#define GROUP_ID @"group.com.krayc.keeping"

#define DATELABEL_HEIGHT 66

@interface TodayViewController () <NCWidgetProviding, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadDB];
    
//    self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 44 + DATELABEL_HEIGHT);
    
    self.taskTableView.delegate = self;
    self.taskTableView.dataSource = self;
    self.taskTableView.emptyDataSetSource = self;
    self.taskTableView.emptyDataSetDelegate = self;
    self.taskTableView.backgroundColor = [UIColor clearColor];
    
    [self.dateLabel setTextColor:[Utilities getColor]];
    [self.dateLabel setFont:[UIFont fontWithName:[Utilities getFont] size:25.0]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    
    [self.dateLabel setText:[DateUtil getTodayDate]];
    
    [self loadTasks];
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.db close];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeCompact) {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, DATELABEL_HEIGHT + 44);
    } else {
        self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, DATELABEL_HEIGHT + self.taskArr.count * 44);
    }
    [self.view reloadInputViews];
}

- (void)loadDB{
    NSString *doc2 = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:GROUP_ID] path];
    NSString *fileName2 = [doc2 stringByAppendingPathComponent:@"task.sqlite"];
    
    NSLog(@"WIDEGT DB PATH %@", fileName2);
    
    self.db = [FMDatabase databaseWithPath:fileName2];
    
    if ([self.db open]){
        NSLog(@"db open");
    }else{
        NSLog(@"db close");
    }
}

- (void)loadTasks{
    self.taskArr = [[NSMutableArray alloc] init];
    FMResultSet *resultSet = [self.db executeQuery:@"select * from t_task;"];
    while ([resultSet next]){
        
        //TODO: TASK UPDATE HERE
        
        Task *t = [Task new];
        t.id = [resultSet intForColumn:@"id"];
        t.name = [resultSet stringForColumn:@"name"];
        
//        NSString *schemeJsonStr = [resultSet stringForColumn:@"appScheme"];
//        if(schemeJsonStr != NULL){
//            NSData *schemeData = [schemeJsonStr dataUsingEncoding:NSUTF8StringEncoding];
//            NSDictionary *schemeDict = [NSJSONSerialization JSONObjectWithData:schemeData options:NSJSONReadingAllowFragments error:nil];
//            t.appScheme = schemeDict;
//        }
//        
//        NSString *daysJsonStr = [resultSet stringForColumn:@"reminderDays"];
//        if(daysJsonStr != NULL){
//            NSData *daysData = [daysJsonStr dataUsingEncoding:NSUTF8StringEncoding];
//            NSArray *daysArr = [NSJSONSerialization JSONObjectWithData:daysData options:NSJSONReadingAllowFragments error:nil];
//            t.reminderDays = daysArr;
//        }
        
        NSString *punchJsonStr = [resultSet stringForColumn:@"punchDateArr"];
        if(punchJsonStr != NULL){
            NSData *punchData = [punchJsonStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *punchArr = [NSJSONSerialization JSONObjectWithData:punchData options:NSJSONReadingAllowFragments error:nil];
            t.punchDateArr = punchArr;
        }
        
//        t.addDate = [resultSet dateForColumn:@"addDate"];
//        t.reminderTime = [resultSet dateForColumn:@"reminderTime"];
//        t.image = [resultSet dataForColumn:@"image"];
//        t.link = [resultSet stringForColumn:@"link"];
//        t.endDate = [resultSet dateForColumn:@"endDate"];
        
        if(![t.punchDateArr containsObject:[DateUtil transformDate:[NSDate date]]]){
            [self.taskArr addObject:t];
        }
        
    }
    
    [self.taskTableView reloadData];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    
//    self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.taskArr.count * 30);
//    
//    [self.view reloadInputViews];

    completionHandler(NCUpdateResultNewData);
}



#pragma mark - Check Delegate

- (void)checkTask:(UITableViewCell *)cell{
    NSIndexPath *path = [self.taskTableView indexPathForCell:cell];
    
    Task *task = self.taskArr[path.row];
    
    [[TaskManager shareInstance]punchForTaskWithID:@(task.id) onDate:[NSDate date]];

    [self loadTasks];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.taskArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KPWidgetTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"KPWidgetTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    KPWidgetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    
    [cell.checkBox setOn:NO];
    
    Task *t;
    t = self.taskArr[indexPath.row];
    [cell.nameLabel setText:t.name];
    
    return cell;
}

#pragma mark - DZNEmpty Delegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = @"今日任务已全部完成";
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [Utilities getColor],
                                 NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:20.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end