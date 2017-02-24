//
//  MainViewController.m
//  444TicTacToe
//
//  Created by Austin on 2/23/17.
//  Copyright © 2017 Austin Wright. All rights reserved.
//

#import "MainViewController.h"
#import "TicTacToeCell.h"
#import "NSString+FontAwesome.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.gameStateMatrix = [self initializeGameState];
    self.isPlayerXTurn = YES;
    // Do any additional setup after loading the view, typically from a nib.
    [self.collectionView reloadData];
}

- (NSMutableArray *)initializeGameState {
    NSMutableArray * rowStates = [@[@0, @0, @0, @0] mutableCopy];
    NSMutableArray * rows = [@[[rowStates mutableCopy], [rowStates mutableCopy], [rowStates mutableCopy], [rowStates mutableCopy]] mutableCopy];
    return rows;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 16;

    // optimized for n,m,k
//    int rowCount = [self.gameStateMatrix count];
//    int columnCount = self.gameStateMatrix[0].count; // assuming we have at least 1 row
//    return rowCount * columnCount;

    // optimized for n,n,k
//    int rowCount = [self.gameStateMatrix count];
//    return rowCount * rowCount; // assumes equal-sided matrix

    // brute force counter:
//    int gridCount = 0;
//    for(NSMutableArray * row in self.gameStateMatrix) {
//        gridCount += row.count;
//    }
//    return gridCount;
}

- (void) awakeFromNib{
    [self.collectionView registerNib:[UINib nibWithNibName:@"TicTacToeCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"TicTacToeCell"];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"TicTacToeCell";
    TicTacToeCell *ticTacToeCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if(!ticTacToeCell) {
        NSLog(@"ticTacToeCell is nil.");
    }

    int cellRow = [self getCellRowForIndexPath:indexPath];
    int cellColumn = [self getCellColumnForIndexPath:indexPath];
    int cellState = [self.gameStateMatrix[(NSUInteger) cellRow][(NSUInteger) cellColumn] intValue];
    if(cellState != GAME_CELL_STATE_EMPTY) {
        [ticTacToeCell.playerTokenLabel setHidden:NO];
        ticTacToeCell.playerTokenLabel.text = cellState == GAME_CELL_STATE_X ? [NSString fa_stringForFontAwesomeIcon:FAIconTimes] : [NSString fa_stringForFontAwesomeIcon:FAIconCircleO];
    } else {
        [ticTacToeCell.playerTokenLabel setHidden:YES];
    }

    return ticTacToeCell;
}

- (int)getCellRowForIndexPath:(NSIndexPath *)indexPath {
    return (int)indexPath.item / self.gameStateMatrix.count; // 0 - 3 will give us 0, 4-7 will give us 1, etc
}


- (int)getCellColumnForIndexPath:(NSIndexPath *)indexPath {
    return (int)indexPath.item % self.gameStateMatrix[0].count; // 0,4,8,12 will give us 0, 1,5,9,13 will give us 1, etc
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int cellRow = [self getCellRowForIndexPath:indexPath];
    int cellColumn = [self getCellColumnForIndexPath:indexPath];
    int newCellState = self.isPlayerXTurn ? 1 : -1;

    self.gameStateMatrix[(NSUInteger) cellRow][(NSUInteger) cellColumn] = @(newCellState);

    self.isPlayerXTurn = !self.isPlayerXTurn;

    [collectionView deselectItemAtIndexPath:indexPath animated:NO];

    [collectionView reloadData];
}

@end
