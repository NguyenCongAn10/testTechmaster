#include <stdint.h>

void selectionSort(int32_t* arr, int32_t n) {
    for (int32_t i = 0; i < n - 1; i++) {
        int32_t minIndex = i;
        for (int32_t j = i + 1; j < n; j++) {
            if (arr[j] < arr[minIndex]) {
                minIndex = j;
            }
        }
        int32_t temp = arr[i];
        arr[i] = arr[minIndex];
        arr[minIndex] = temp;
    }
}
