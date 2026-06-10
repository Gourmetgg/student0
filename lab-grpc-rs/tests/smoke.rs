//! Integration smoke test for the gRPC lab.
//!
//! Spawns the built `client` binary with `--help` and asserts a clean exit.
//! The `server` binary in this lab does not accept CLI flags — it binds to a
//! fixed port and runs forever — so this test verifies that the crate
//! compiles and produces a working clap-driven client. The full
//! client/server round-trip is exercised by `cargo test` against `src/test.rs`
//! once the student has implemented the RPC methods.

use std::process::Command;

#[test]
fn client_help_exits_zero() {
    let bin = env!("CARGO_BIN_EXE_client");
    let output = Command::new(bin)
        .arg("--help")
        .output()
        .expect("failed to spawn client");
    assert!(
        output.status.success(),
        "client --help should exit 0, got {:?}\nstderr: {}",
        output.status,
        String::from_utf8_lossy(&output.stderr),
    );
}

#[test]
fn server_binary_exists() {
    let bin = env!("CARGO_BIN_EXE_server");
    assert!(
        std::path::Path::new(bin).exists(),
        "server binary should have been built at {bin}",
    );
}
