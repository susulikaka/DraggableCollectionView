//
//  ViewController.m
//  EditableCollectionView
//
//  Created by SupingLi on 16/8/29.
//  Copyright © 2016年 SupingLi. All rights reserved.
//

#import "ViewController.h"
#import "TextCollectionViewCell.h"
#import "ImgCollectionViewCell.h"
#import "SomeCollectionView.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSMutableArray * dataSource;
//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UILongPressGestureRecognizer *longGesture;
@property (strong, nonatomic) NSIndexPath *curLocation;
@property (assign, nonatomic) CGPoint oldLocation;
@property (strong, nonatomic) UIView * mappingCell;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initInterface];
}

#pragma mark - action

- (IBAction)editAction:(id)sender {
    UIButton * btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    [self.collectionView reloadData];
}

#pragma mark - private method

- (void)initInterface {
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImgCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([ImgCollectionViewCell class])];
    [self.collectionView registerNib:[UINib nibWithNibName:@"TextCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([TextCollectionViewCell class])];
    self.dataSource = [NSMutableArray arrayWithObjects:@"aaa",@"bbb",@"ccc",@"ddd",@"1",@"eee",@"fff",@"ggg",@"hhh",@"aaa",@"bbb",@"ccc",@"ddd",@"1",@"eee",@"fff",@"ggg",@"hhh", nil];
    self.collectionView.backgroundColor = [UIColor whiteColor];
   
    [self.view addSubview:self.collectionView];
    [self.view addGestureRecognizer:self.longGesture];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChange:) name:@"textChange" object:nil];
    
    
}

- (void)textChange:(NSNotification *)noti {
    NSLog(@"-------%lf,%lf",self.collectionView.contentSize.width,self.collectionView.contentSize.height);
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        CGPoint location = [gesture locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
        if (!indexPath || indexPath.row == 0) {
            return;
        }
        self.oldLocation = location;
        self.curLocation = indexPath;
        UICollectionViewCell * targetCell = [self.collectionView cellForItemAtIndexPath:indexPath];
        UIView * cellView = [targetCell snapshotViewAfterScreenUpdates:YES];
        self.mappingCell = cellView;
        self.mappingCell.frame = cellView.frame;
        
        [targetCell setHidden:YES];
        [self.collectionView addSubview:self.mappingCell];
        cellView.center = targetCell.center;
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint point = [gesture locationInView:self.collectionView];
        self.mappingCell.center = point;
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (![indexPath isEqual:self.curLocation] && indexPath.row != 0) {
            [self.collectionView moveItemAtIndexPath:self.curLocation toIndexPath:indexPath];
            self.curLocation = indexPath;
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.curLocation];
        if (!cell) {
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:self.oldLocation];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
            cell = [self.collectionView cellForItemAtIndexPath:newIndexPath];
            [self.collectionView moveItemAtIndexPath:self.curLocation toIndexPath:newIndexPath];
        }
        [UIView animateWithDuration:0.2
                              delay:0
             usingSpringWithDamping:1
              initialSpringVelocity:1
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
             if (cell) {
                 self.mappingCell.center = cell.center;
             } else {
                 self.mappingCell.center = self.oldLocation;
             }
        } completion:^(BOOL finished) {
            
            [self.mappingCell removeFromSuperview];
            cell.hidden = NO;
            self.mappingCell = nil;
            self.curLocation = nil;
            
        }];
    }
}

- (void)setCollectionView {
}

#pragma mark - delegate


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(CGRectGetWidth(self.view.bounds), 30);
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    id xx = self.dataSource[sourceIndexPath.row];
    [self.dataSource removeObjectAtIndex:sourceIndexPath.row];
    [self.dataSource insertObject:xx atIndex:destinationIndexPath.row];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TextCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TextCollectionViewCell class]) forIndexPath:indexPath];
    [cell renderWithBlock:^(id obj) {
        [self.dataSource replaceObjectAtIndex:indexPath.row withObject:obj];
        [self.collectionView reloadData];
    }];
    cell.text.text = self.dataSource[indexPath.row];
    return cell;
}

- (UILongPressGestureRecognizer *)longGesture {
    if (!_longGesture) {
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        _longGesture.minimumPressDuration = 0.2;
    }
    return _longGesture;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
//        layout.estimatedItemSize = CGSizeMake(self.view.bounds.size.width, 100);
//        layout.itemSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 30);
        _collectionView =  [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-140) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
