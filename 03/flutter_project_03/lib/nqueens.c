#include <stdio.h>
#include <stdlib.h>

int solutions[92][8];
int solutionCount = 0;

int isSafe(int queens[], int row, int col) {
    for (int i = 0; i < row; i++) {
        int placedCol = queens[i];
        if (placedCol == col || // Cùng cột
            placedCol - i == col - row || // Đường chéo chính
            placedCol + i == col + row) { // Đường chéo phụ
            return 0;
        }
    }
    return 1;
}

void backtrack(int queens[], int row) {
    if (row == 8) {
        for (int i = 0; i < 8; i++) {
            solutions[solutionCount][i] = queens[i];
        }
        solutionCount++;
        return;
    }
    for (int col = 0; col < 8; col++) {
        if (isSafe(queens, row, col)) {
            queens[row] = col;
            backtrack(queens, row + 1);
            queens[row] = -1; // Quay lui
        }
    }
}

int* getSolutions(int* count) {
    int queens[8] = {-1, -1, -1, -1, -1, -1, -1, -1};
    solutionCount = 0;
    backtrack(queens, 0);
    *count = solutionCount;
    return (int*)solutions;
}