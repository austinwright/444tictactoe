//
//  MainViewController.h
//  444TicTacToe
//
//  Created by Austin on 2/23/17.
//  Copyright © 2017 Austin Wright. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSNumber *> *> *gameStateMatrix;
@property (nonatomic) BOOL isPlayerXTurn;

@end

typedef enum {
    GAME_CELL_STATE_O = -1,
    GAME_CELL_STATE_EMPTY,
    GAME_CELL_STATE_X
} GAME_CELL_STATE;

