//! Integration smoke test for HW 3 (Rust HTTP server).
//!
//! Spawns the built `http_server_rs` binary with `--help` and asserts a
//! clean exit. This proves the crate builds and the CLI is wired up; deeper
//! request/response tests live alongside the student implementation in
//! `src/tests/`.

use std::process::Command;

#[test]
fn binary_help_exits_zero() {
    let bin = env!("CARGO_BIN_EXE_http_server_rs");
    let output = Command::new(bin)
        .arg("--help")
        .output()
        .expect("failed to spawn http_server_rs");
    assert!(
        output.status.success(),
        "--help should exit 0, got {:?}\nstderr: {}",
        output.status,
        String::from_utf8_lossy(&output.stderr),
    );
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("--files"), "help text should mention --files");
}
