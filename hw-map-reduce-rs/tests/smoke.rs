//! Integration smoke test for HW 5 (Rust MapReduce).
//!
//! Confirms the three CLI binaries build and respond to `--help`. End-to-end
//! cluster tests live in `src/tests/mod.rs` and remain `#[ignore]`d so they
//! do not block default `cargo test` on starter code.

use std::process::Command;

fn assert_help_ok(name: &'static str, bin: &str) {
    let output = Command::new(bin)
        .arg("--help")
        .output()
        .unwrap_or_else(|e| panic!("failed to spawn {name}: {e}"));
    assert!(
        output.status.success(),
        "{name} --help should exit 0, got {:?}\nstderr: {}",
        output.status,
        String::from_utf8_lossy(&output.stderr),
    );
}

#[test]
fn coordinator_help_exits_zero() {
    assert_help_ok("mr-coordinator", env!("CARGO_BIN_EXE_mr-coordinator"));
}

#[test]
fn worker_help_exits_zero() {
    assert_help_ok("mr-worker", env!("CARGO_BIN_EXE_mr-worker"));
}

#[test]
fn client_help_exits_zero() {
    assert_help_ok("mr-client", env!("CARGO_BIN_EXE_mr-client"));
}
