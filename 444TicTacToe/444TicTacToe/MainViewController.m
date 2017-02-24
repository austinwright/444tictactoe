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
#import "BButton.h"
#import "CurrentPlayerHeaderView.h"
#import "StartNewGameFooterView.h"

#define LEFT_RIGHT_CONTENT_INSET 50
#define HEADER_FOOTER_HEIGHT 100

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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
        ticTacToeCell.playerTokenLabel.text = cellState == GAME_CELL_STATE_X ? @"X" : @"O";//[NSString fa_stringForFontAwesomeIcon:FAIconTimes] : [NSString fa_stringForFontAwesomeIcon:FAIconCircleO];
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
            NSString *currentPlayerString = self.isPlayerXTurn ? @"X" : @"O";
            NSString *winString = [NSString stringWithFormat:@"Player %@ Wins!", currentPlayerString];
            UIAlertController *winAlert = [UIAlertController alertControllerWithTitle:winString
                                                                              message:@"Play Again?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction * startNewGameAction = [UIAlertAction actionWithTitle:@"New Game"
                                                                          style:UIAlertActionStyleDefault
                                                                        handler:^(UIAlertAction *action) {
                                                                            [self startNewGameButtonClicked:self];
                                                                        }];

            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Not Yet ..."
                                                                          style:UIAlertActionStyleCancel
                                                                        handler:nil];

            [winAlert addAction:cancelAction];
            [winAlert addAction:startNewGameAction];
            [self presentViewController:winAlert animated:YES completion:nil];

        } else {
            self.isPlayerXTurn = !self.isPlayerXTurn;
        }

        [collectionView reloadData];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;

    if (kind == UICollectionElementKindSectionHeader) {
        CurrentPlayerHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                 withReuseIdentifier:@"CurrentPlayerHeaderView" forIndexPath:indexPath];
        NSString *XorO = [self isPlayerXTurn] ? @"X":@"O";//
        // [NSString stringWithFormat:@"%@", [NSString fa_stringForFontAwesomeIcon:FAIconTimes]] :
        //        [NSString stringWithFormat:@"%@", [NSString fa_stringForFontAwesomeIcon:FAIconCircleO]];
        headerView.currentPlayerLabel.text = XorO;
        reusableView = headerView;
    }

    if (kind == UICollectionElementKindSectionFooter) {
        StartNewGameFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:@"StartNewGameFooterView" forIndexPath:indexPath];
//        footerView.startNewGameButton = [BButton buttonWithType:UIButtonTypeCustom];
//        [footerView.startNewGameButton setStyle:BButtonStyleBootstrapV3];
//        [footerView.startNewGameButton setButtonCornerRadius:@0];
//        // todo: find out why BButton is misbehaving
//        [footerView.startNewGameButton setBackgroundColor:[UIColor cyanColor]];//[UIColor colorWithRed:0.0f green:189/255 blue:172/255 alpha:0.0f]];
//        [footerView.startNewGameButton titleLabel].backgroundColor = [UIColor cyanColor];
//        [footerView.startNewGameButton titleLabel].textColor = [UIColor whiteColor];
//        [footerView.startNewGameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal | UIControlStateSelected | UIControlStateHighlighted];

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
    // if any count adds up to |4|, return true

    // finite checks first
    //check for 0,0 diagonal
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

    // todo: check for 2x2
    // 0,0 ; 0,1 ; 1,0 ; 1,1 to 0,2 ; 0,3 ; 1,2 ; 1,3
    // 1,0 ; 1,1 ; 2,0 ; 2,1 to 1,2 ; 1,3 ; 2,2 ; 2,3
    // 2,0;2,1;2,0;2,1 to 0,2;0,3;1,2;1,3
    // 2,0;2,1;2,0;2,1 to 0,2;0,3;1,2;1,3
    int squareCount = self.gameStateMatrix[0][0].intValue + self.gameStateMatrix[0][1].intValue +
            self.gameStateMatrix[1][0].intValue + self.gameStateMatrix[1][1].intValue;

    // 1st pass brute force:
    // check for horizontal
    //check for vertical
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
        }
        // done with a row, check for win
        if(abs(horizontalCount) >= 4) {
            return YES;
        }
    }
    for(NSNumber* verticalCount in verticalCountArray) {
        if(abs([verticalCount intValue]) >= 4) {
            return YES;
        }
    }

    return NO;
}

@end
