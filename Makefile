# Repo-level convenience targets. The real entry points are
# `bash run_all_tests.sh` and `bash <hw>/tests/run.sh`.

.PHONY: test test-full clean

test:
	bash run_all_tests.sh

test-full:
	RUN_FULL=1 bash run_all_tests.sh

clean:
	@for d in hw-intro hw-intro/words hw-list hw-shell hw-http \
	          hw-memory/mm_alloc hw-map-reduce lab-rpc; do \
	  if [ -f "$$d/Makefile" ]; then echo "==> clean $$d"; $(MAKE) -C "$$d" clean || true; fi; \
	done
	@for d in hw-http-rs hw-map-reduce-rs lab-grpc-rs; do \
	  if [ -f "$$d/Cargo.toml" ]; then echo "==> cargo clean $$d"; (cd "$$d" && cargo clean); fi; \
	done
	@if [ -d proj-pregame/src/threads ]; then echo "==> clean proj-pregame"; $(MAKE) -C proj-pregame/src/threads clean || true; fi
	@if [ -d hw-memory/pintos/src/threads ]; then echo "==> clean hw-memory pintos"; $(MAKE) -C hw-memory/pintos/src/threads clean || true; fi
