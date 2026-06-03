#ifndef CWOFF2_H
#define CWOFF2_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
  CWOFF2Success = 0,
  CWOFF2InvalidInput = 1,
  CWOFF2DecodeFailure = 2,
  CWOFF2AllocationFailure = 3
} CWOFF2Status;

typedef struct {
  uint8_t *bytes;
  size_t count;
} CWOFF2Data;

CWOFF2Status CWOFF2Decompress(
  const uint8_t *bytes,
  size_t count,
  CWOFF2Data *output
);

void CWOFF2DataFree(CWOFF2Data data);

#ifdef __cplusplus
}
#endif

#endif
