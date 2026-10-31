/* support.c (qosapp) -- the freestanding floor under the app image.
 *
 * The image links -nostdlib, but gcc at -O2 freely emits calls to
 * memcpy/memset/memmove/memcmp for struct copies and open-coded loops
 * (bare-metal virt gets away without these only because riscv gcc's
 * -ffreestanding codegen happens not to emit them for this codebase;
 * x86-64 gcc does).  Byte loops, deliberately: correctness floor, and
 * the runtime's hot paths don't route through these anyway. */
#include <stddef.h>

void *memcpy(void *dst, const void *src, size_t n) {
  unsigned char *d = dst;
  const unsigned char *s = src;
  while (n--) *d++ = *s++;
  return dst;
}

void *memset(void *dst, int c, size_t n) {
  unsigned char *d = dst;
  while (n--) *d++ = (unsigned char)c;
  return dst;
}

void *memmove(void *dst, const void *src, size_t n) {
  unsigned char *d = dst;
  const unsigned char *s = src;
  if (d < s)
    while (n--) *d++ = *s++;
  else {
    d += n;
    s += n;
    while (n--) *--d = *--s;
  }
  return dst;
}

int memcmp(const void *a, const void *b, size_t n) {
  const unsigned char *x = a, *y = b;
  for (; n--; x++, y++)
    if (*x != *y) return *x - *y;
  return 0;
}

size_t strlen(const char *s) {
  size_t n = 0;
  while (s[n]) n++;
  return n;
}
