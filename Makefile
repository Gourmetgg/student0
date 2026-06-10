.PHONY: test test-full clean

test:
	bash run_all_tests.sh

test-full:
	RUN_FULL=1 bash run_all_tests.sh

clean:
	@for d in hw-intro hw-list hw-shell hw-http hw-http-rs hw-memory/mm_alloc \
	          hw-map-reduce hw-map-reduce-rs lab-rpc lab-grpc-rs proj-pregame; do \
	  if [ -d "$$d" ]; then echo "==> clean $$d"; $(MAKE) -C "$$d" clean || true; fi; \
	done
