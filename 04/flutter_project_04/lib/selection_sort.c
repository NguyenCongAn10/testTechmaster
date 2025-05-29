#include <stdint.h>

// Cấu trúc để lưu trạng thái của mỗi bước
typedef struct {
    int current; // Vị trí hiện tại (i)
    int compare; // Vị trí đang so sánh (j)
    int min;     // Vị trí số nhỏ nhất
    int swap;    // Có hoán đổi không (1: có, 0: không)
    int stepType; // 0: So sánh, 1: Cập nhật min, 2: Hoán đổi
    int array[100]; // Mảng hiện tại
} SortStep;

// Hàm chính để sắp xếp và lưu các bước
void selectionSortWithSteps(int arr[], int n, SortStep steps[], int* stepCount) {
    int stepIndex = 0;

    for (int i = 0; i < n - 1; i++) {
        int min_idx = i;

        for (int j = i + 1; j < n; j++) {
            // Ghi lại bước so sánh
            steps[stepIndex].current = i;
            steps[stepIndex].compare = j;
            steps[stepIndex].min = min_idx;
            steps[stepIndex].swap = 0;
            steps[stepIndex].stepType = 0;
            for (int k = 0; k < n; k++) steps[stepIndex].array[k] = arr[k];
            stepIndex++;

            if (arr[j] < arr[min_idx]) {
                min_idx = j;
                // Ghi lại bước cập nhật min
                steps[stepIndex].current = i;
                steps[stepIndex].compare = -1;
                steps[stepIndex].min = min_idx;
                steps[stepIndex].swap = 0;
                steps[stepIndex].stepType = 1;
                for (int k = 0; k < n; k++) steps[stepIndex].array[k] = arr[k];
                stepIndex++;
            }
        }

        if (min_idx != i) {
            // Hoán đổi
            int temp = arr[i];
            arr[i] = arr[min_idx];
            arr[min_idx] = temp;

            // Ghi lại bước hoán đổi
            steps[stepIndex].current = i;
            steps[stepIndex].compare = -1;
            steps[stepIndex].min = min_idx;
            steps[stepIndex].swap = 1;
            steps[stepIndex].stepType = 2;
            for (int k = 0; k < n; k++) steps[stepIndex].array[k] = arr[k];
            stepIndex++;
        }
    }

    *stepCount = stepIndex;
}
