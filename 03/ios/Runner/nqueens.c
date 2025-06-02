#include <stdio.h>
#include <stdlib.h>

#define MAX_SOLUTIONS 92
#define BOARD_SIZE 8

// Biến toàn cục lưu nghiệm tạm thời
int tempSolutions[MAX_SOLUTIONS][BOARD_SIZE];
int solutionCount = 0;

// Kiểm tra vị trí đặt hậu có an toàn
int isSafe(int queens[], int row, int col) {
    for (int i = 0; i < row; i++) {
        int placedCol = queens[i];
        if (placedCol == col || placedCol - i == col - row || placedCol + i == col + row) {
            return 0; // Không an toàn
        }
    }
    return 1; // An toàn
}

// Đệ quy tìm tất cả nghiệm
void backtrack(int queens[], int row) {
    if (row == BOARD_SIZE) {
        for (int i = 0; i < BOARD_SIZE; i++) {
            tempSolutions[solutionCount][i] = queens[i];
        }
        solutionCount++;
        return;
    }
    for (int col = 0; col < BOARD_SIZE; col++) {
        if (isSafe(queens, row, col)) {
            queens[row] = col;
            backtrack(queens, row + 1);
            queens[row] = -1;
        }
    }
}

// Trả về con trỏ tới mảng nghiệm, gán số nghiệm qua con trỏ count
int* getSolutions(int* count) {
    if (count == NULL) return NULL;

    int queens[BOARD_SIZE];
    for (int i = 0; i < BOARD_SIZE; i++) {
        queens[i] = -1;
    }
    solutionCount = 0;

    backtrack(queens, 0);

    *count = solutionCount;

    // In debug
    printf("Total solutions found: %d\n", solutionCount);

    int* flat = (int*)malloc(sizeof(int) * solutionCount * BOARD_SIZE);
    if (flat == NULL) return NULL;

    for (int i = 0; i < solutionCount; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            flat[i * BOARD_SIZE + j] = tempSolutions[i][j];
        }
    }

    return flat;
}

// Giải phóng bộ nhớ đã cấp phát
void freeSolutions(int* ptr) {
    if (ptr != NULL) {
        free(ptr);
    }
}
