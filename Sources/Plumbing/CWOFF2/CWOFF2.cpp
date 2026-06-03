#include "CWOFF2.h"

#include <cstdlib>
#include <cstring>
#include <string>
#include <woff2/decode.h>
#include <woff2/output.h>

CWOFF2Status CWOFF2Decompress(
  const uint8_t *bytes,
  size_t count,
  CWOFF2Data *output
) {
  if (output == nullptr) return CWOFF2InvalidInput;
  output->bytes = nullptr;
  output->count = 0;

  if (bytes == nullptr || count == 0) return CWOFF2InvalidInput;

  std::string decompressed;
  woff2::WOFF2StringOut writer(&decompressed);

  if (!woff2::ConvertWOFF2ToTTF(bytes, count, &writer)) {
    return CWOFF2DecodeFailure;
  }

  if (decompressed.empty()) return CWOFF2DecodeFailure;

  auto *result = static_cast<uint8_t *>(std::malloc(decompressed.size()));
  if (result == nullptr) return CWOFF2AllocationFailure;

  std::memcpy(result, decompressed.data(), decompressed.size());
  output->bytes = result;
  output->count = decompressed.size();

  return CWOFF2Success;
}

void CWOFF2DataFree(CWOFF2Data data) {
  std::free(data.bytes);
}
