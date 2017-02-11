//
//  KPSettingsTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPSettingsTableViewController.h"
#import "Utilities.h"
#import <LeanCloudFeedback/LeanCloudFeedback.h>

@interface KPSettingsTableViewController ()

@end

@implementation KPSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.animationSwitch setOnTintColor:[Utilities getColor]];
    [self.animationSwitch setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"animation"]];
    
    //设置版本号
    self.versionLabel.text = [NSString stringWithFormat:@"v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    //动画开关
    [self.animationSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setFont];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)switchChange:(id)sender{
    switch ([sender tag]){
            //tag == 0: 动画开关
        case 0:
        {
            [[NSUserDefaults standardUserDefaults] setBool:self.animationSwitch.isOn forKey:@"animation"];
        }
            break;
    }
}

- (void)setFont{
    [self.fontLabel setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
    [self.mailLabel setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
    [self.animationLabel setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
    [self.scoreLabel setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
    [self.numberLabel setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
    [self.versionLabel setFont:[UIFont fontWithName:[Utilities getFont] size:17.0]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
//        case 1:
//            return 1;
        case 1:
            return 3;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"通用";
//        case 1:
//            return @"偏好";
        case 1:
            return @"其他";
        default:
            return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1 && indexPath.row == 0){
        [self scoreApp];
    }else if(indexPath.section == 1 && indexPath.row == 1){
        LCUserFeedbackAgent *agent = [LCUserFeedbackAgent sharedInstance];
        [agent showConversations:self title:nil contact:nil];
    }
}

#pragma mark - Go to Score

- (void)scoreApp{
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [Utilities getAPPID]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]
                                       options:@{}
                             completionHandler:nil];
}

@end
