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
#import "CurrentPlayerHeaderView.h"
#import "StartNewGameFooterView.h"

#define LEFT_RIGHT_CONTENT_INSET 50
#define HEADER_FOOTER_HEIGHT 125

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.crossIcon = [NSString fa_stringForFontAwesomeIcon:FAIconTimes];
    self.circleIcon = [NSString fa_stringForFontAwesomeIcon:FAIconCircleO];
    
    [self initializeGameState];
    [self.collectionView reloadData];
}

- (void)initializeGameState {
    self.isPlayerXTurn = YES;
    NSMutableArray * rowStates = [@[@0, @0, @0, @0] mutableCopy];
    NSMutableArray * rows = [@[[rowStates mutableCopy], [rowStates mutableCopy], [rowStates mutableCopy], [rowStates mutableCopy]] mutableCopy];
    self.gameStateMatrix = rows;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CGFloat screenWidth = self.collectionView.bounds.size.width;
    CGFloat screenHeight = self.collectionView.bounds.size.height;
    int numRows = (int) self.gameStateMatrix.count;
    int numColumns = (int) self.gameStateMatrix[0].count;

    // width less insets, less 1px spacing between cells, divided by number of columns
    self.maximizedCellWidth = (screenWidth - LEFT_RIGHT_CONTENT_INSET*2 - (numColumns-1) ) / numColumns;

    // height of the collection, less the header and footer, less the space between cells, less the size of the cells, divided by 2
    self.maximizedTopBottomInset = (screenHeight - (HEADER_FOOTER_HEIGHT * 2) - (numRows - 1) - (numRows * self.maximizedCellWidth) ) / 2;
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

    // optimized for n,m,k with at least 1 row
//    int rowCount = [self.gameStateMatrix count];
//    int columnCount = self.gameStateMatrix[0].count; // assuming we have at least 1 row
//    return rowCount * columnCount;
}

- (void) awakeFromNib{
    [self.collectionView registerNib:[UINib nibWithNibName:@"TicTacToeCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"TicTacToeCell"];
    [super awakeFromNib];
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
        ticTacToeCell.playerTokenLabel.text = cellState == GAME_CELL_STATE_X ? self.crossIcon : self.circleIcon;
    } else {
        ticTacToeCell.userInteractionEnabled = YES;
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
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];

    TicTacToeCell *cell = (TicTacToeCell *) [collectionView cellForItemAtIndexPath:indexPath];

    int cellRow = [self getCellRowForIndexPath:indexPath];
    int cellColumn = [self getCellColumnForIndexPath:indexPath];
    int currentCellState = [self.gameStateMatrix[(NSUInteger) cellRow][(NSUInteger) cellColumn] intValue];
    int newCellState = self.isPlayerXTurn ? 1 : -1;


    if(currentCellState == GAME_CELL_STATE_EMPTY) {
        self.gameStateMatrix[(NSUInteger) cellRow][(NSUInteger) cellColumn] = @(newCellState);
        cell.userInteractionEnabled = NO;

        if([self checkForWinCondition]) {
            NSString *currentPlayerString = self.isPlayerXTurn ? self.crossIcon : self.circleIcon;
            NSString *winString = [NSString stringWithFormat:@"Player %@ Wins!", currentPlayerString];
            NSMutableAttributedString *attributedWinString = [[NSMutableAttributedString alloc] initWithString:winString];
            [attributedWinString addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:@"FontAwesome" size:20]
                                        range:NSMakeRange(7,1)];
            [self presentEndGameAlertWithTitle:winString optionalAttributedTitle:attributedWinString];
        } else if([self checkForDrawCondition]) {
            [self presentEndGameAlertWithTitle:@"It's a Draw!" optionalAttributedTitle:nil];
        } else {
            self.isPlayerXTurn = !self.isPlayerXTurn;
        }

        [collectionView reloadData];
    }
}

- (void)presentEndGameAlertWithTitle:(NSString*)titleString optionalAttributedTitle:(NSAttributedString * _Nullable)attributedString {
    UIAlertController *endGameAlert = [UIAlertController alertControllerWithTitle:titleString
                                                                      message:@"Play Again?"
                                                               preferredStyle:UIAlertControllerStyleAlert];
    
    if(attributedString) [endGameAlert setValue:attributedString forKey:@"attributedTitle"]; // not sure if private API ...

    UIAlertAction * startNewGameAction = [UIAlertAction actionWithTitle:@"New Game"
                                                                  style:UIAlertActionStyleDestructive
                                                                handler:^(UIAlertAction *action) {
                                                                    [self startNewGameButtonClicked:self];
                                                                }];

    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Not Yet ..."
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];

    [endGameAlert addAction:cancelAction];
    [endGameAlert addAction:startNewGameAction];
    [self presentViewController:endGameAlert animated:YES completion:nil];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;

    if (kind == UICollectionElementKindSectionHeader) {
        CurrentPlayerHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                 withReuseIdentifier:@"CurrentPlayerHeaderView" forIndexPath:indexPath];
        NSString *XorO = [self isPlayerXTurn] ? self.crossIcon : self.circleIcon;
        headerView.currentPlayerLabel.text = XorO;
        reusableView = headerView;
    }

    if (kind == UICollectionElementKindSectionFooter) {
        StartNewGameFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:@"StartNewGameFooterView" forIndexPath:indexPath];
        reusableView = footerView;
    }

    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize result = CGSizeMake(self.maximizedCellWidth,self.maximizedCellWidth);
    return result;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    UIEdgeInsets result = UIEdgeInsetsMake(self.maximizedTopBottomInset, LEFT_RIGHT_CONTENT_INSET, self.maximizedTopBottomInset, LEFT_RIGHT_CONTENT_INSET);
    return result;
}


- (IBAction)startNewGameButtonClicked:(id)sender {
    [self initializeGameState];
    [self.collectionView reloadData];
}

-(BOOL)checkForWinCondition {
    // self.gameStateMatrix[<Y INDEX>][<X INDEX>]
    // if any count adds up to |4| (or more), return true

    // finite checks first
    // check for 0,0 diagonal
    int backSlashDiagonal = self.gameStateMatrix[0][0].intValue + self.gameStateMatrix[1][1].intValue +
            self.gameStateMatrix[2][2].intValue + self.gameStateMatrix[3][3].intValue;
    if(abs(backSlashDiagonal) >= 4) {
        return YES;
    }

    //check for 3,0 diagonal
    int forwardSlashDiagonal = self.gameStateMatrix[0][3].intValue + self.gameStateMatrix[1][2].intValue +
            self.gameStateMatrix[2][1].intValue + self.gameStateMatrix[3][0].intValue;
    if(abs(forwardSlashDiagonal) >= 4) {
        return YES;
    }

    //check for corners
    int fourCorners = self.gameStateMatrix[0][0].intValue + self.gameStateMatrix[0][3].intValue +
            self.gameStateMatrix[3][0].intValue + self.gameStateMatrix[3][3].intValue;
    if(abs(fourCorners) >= 4) {
        return YES;
    }

    NSMutableArray <NSNumber*>* verticalCountArray = [NSMutableArray arrayWithCapacity:self.gameStateMatrix.count];
    // init the array just in case
    // todo verify if needed
    for(id i in self.gameStateMatrix) {
        [verticalCountArray addObject:@0];
    }
    for(int rowIndex = 0; rowIndex < self.gameStateMatrix.count; rowIndex++) {
        int horizontalCount = 0;
        for(int columnIndex = 0; columnIndex < self.gameStateMatrix[0].count ;columnIndex ++) {
            NSNumber * cellValue = self.gameStateMatrix[(NSUInteger) rowIndex][(NSUInteger) columnIndex];
            NSNumber * verticalCount = verticalCountArray[(NSUInteger) columnIndex];
            horizontalCount += [cellValue intValue];
            verticalCountArray[(NSUInteger) columnIndex] = @([cellValue intValue] + [verticalCount intValue]); // increment the column counter

            // check for 2x2 squares
            if(rowIndex < self.gameStateMatrix.count - 1 && columnIndex < self.gameStateMatrix[0].count - 1) { // skip the last row and column
                int squareCount = self.gameStateMatrix[(NSUInteger) rowIndex][(NSUInteger) columnIndex].intValue +
                        self.gameStateMatrix[(NSUInteger) rowIndex][(NSUInteger) (columnIndex + 1)].intValue +
                        self.gameStateMatrix[(NSUInteger) (rowIndex + 1)][(NSUInteger) columnIndex].intValue +
                        self.gameStateMatrix[(NSUInteger) (rowIndex + 1)][(NSUInteger) (columnIndex + 1)].intValue;
                if(abs(squareCount) >= 4) {
                    return YES;
                }
            }
        }
        // done with a row, check for horizontal win condition
        if(abs(horizontalCount) >= 4) {
            return YES;
        }
    }
    //check for vertical winConditions
    for(NSNumber* verticalCount in verticalCountArray) {
        if(abs([verticalCount intValue]) >= 4) {
            return YES;
        }
    }

    return NO;
}

-(BOOL)checkForDrawCondition {
    for(NSMutableArray <NSNumber*>* row in self.gameStateMatrix) {
        if([row containsObject:@0]) {
            return NO;
        }
    }
    return YES;
}

@end
