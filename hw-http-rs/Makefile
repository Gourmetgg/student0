.PHONY: all build run test

all: build


build:
	cargo build --release

install:
	cargo install --path .

run: build
	./target/debug/http_server_rs --files www/

test:
	cargo test --test smoke
