//! Shared helpers for hw-map-reduce-rs integration tests. Black-box: spawns
//! the built binaries, so this compiles against the pristine starter.

use std::process::{Child, Command, Output};
use std::time::Duration;

pub struct ProcGuard(pub Child);

impl Drop for ProcGuard {
    fn drop(&mut self) {
        let _ = self.0.kill();
        let _ = self.0.wait();
    }
}

pub fn spawn_coordinator() -> ProcGuard {
    let child = Command::new(env!("CARGO_BIN_EXE_mr-coordinator"))
        .spawn()
        .expect("spawn mr-coordinator");
    std::thread::sleep(Duration::from_millis(800));
    ProcGuard(child)
}

pub fn spawn_worker() -> ProcGuard {
    let child = Command::new(env!("CARGO_BIN_EXE_mr-worker"))
        .spawn()
        .expect("spawn mr-worker");
    ProcGuard(child)
}

/// Run `mr-client <args>` to completion and return its output.
pub fn client(args: &[&str]) -> Output {
    Command::new(env!("CARGO_BIN_EXE_mr-client"))
        .args(args)
        .output()
        .expect("run mr-client")
}
