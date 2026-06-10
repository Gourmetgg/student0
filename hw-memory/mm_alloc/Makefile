CFLAGS=-g3 -Wall -Werror -Wextra -std=c99 -D_POSIX_SOURCE -D_DEFAULT_SOURCE -D_XOPEN_SOURCE=700 -fPIC
TEST_CFLAGS=-Wl,-rpath=.
TEST_LDFLAGS=-ldl

all: hw3lib.so mm_test

hw3lib.so: mm_alloc.o
	gcc -shared -o $@ $^

mm_alloc.o: mm_alloc.c
	gcc $(CFLAGS) -c -o $@ $^

mm_test: mm_test.c
	gcc $(CFLAGS) $(TEST_CFLAGS) -o $@ $^ $(TEST_LDFLAGS)

clean:
	rm -rf hw3lib.so mm_alloc.o mm_test

# Smoke test. The starter code does not compile under -Werror=unused-parameter,
# so on the unmodified starter this target reports SKIP rather than failing.
.PHONY: test
test:
	@if make all >/tmp/mm_alloc-build.log 2>&1; then \
	  echo "PASS: mm_alloc built"; \
	  ./mm_test && echo "PASS: mm_test ran" || { echo "FAIL: mm_test"; exit 1; }; \
	else \
	  echo "SKIP: mm_alloc starter does not compile (implement mm_malloc/mm_realloc/mm_free)"; \
	fi
