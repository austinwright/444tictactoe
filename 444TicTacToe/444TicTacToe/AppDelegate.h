//
//  AppDelegate.h
//  444TicTacToe
//
//  Created by Austin on 2/23/17.
//  Copyright © 2017 Austin Wright. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

