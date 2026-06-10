//! Black-box behavior tests for the Fall 2025 hw-map-reduce-rs coordinator.
//!
//! `#[ignore]`d so the pristine starter compiles and stays green; opt in with
//!
//!     cargo test --test behavior -- --ignored --test-threads=1
//!
//! (single-threaded: every test owns the one coordinator address). Or via the
//! framework: `RUN_FULL=1 bash tests/run.sh`. Handout citations are Sp25
//! captures of pages confirmed present in Fall25.

mod common;

use common::{client, spawn_coordinator, spawn_worker};

/// docs/job-submission + docs/tasks: a wc job completes end-to-end and
/// `process` emits non-empty output. Mirrors the autograder's `wc` family.
#[test]
#[ignore]
fn e2e_wc_job_completes() {
    let _c = spawn_coordinator();
    let _w1 = spawn_worker();
    let _w2 = spawn_worker();

    let out_dir = tempdir();
    let submit = client(&[
        "submit",
        "data/gutenberg/p.txt",
        "data/gutenberg/q.txt",
        "-a",
        "wc",
        "-n",
        "2",
        "-o",
        &out_dir,
        "--wait=true",
    ]);
    assert!(
        submit.status.success(),
        "submit --wait failed:\nstdout: {}\nstderr: {}",
        String::from_utf8_lossy(&submit.stdout),
        String::from_utf8_lossy(&submit.stderr)
    );

    let process = client(&["process", "-a", "wc", "-n", "2", "-o", &out_dir]);
    assert!(process.status.success(), "process failed");
    let text = String::from_utf8_lossy(&process.stdout);
    assert!(!text.trim().is_empty(), "wc output is empty");
    // Spot-check: a token that certainly appears in Gutenberg English prose.
    assert!(
        text.contains("the"),
        "expected the word 'the' somewhere in wc output:\n{}",
        &text[..text.len().min(400)]
    );
}

/// TODO(you): docs/job-submission (Job Queueing) — FCFS with no idle workers.
/// Mirrors `mr-queue-order` / `queue-map-multiple`.
#[test]
#[ignore]
fn todo_fcfs_queue_order() {
    unimplemented!(
        "submit two jobs with ONE worker; add log::info! per GetTask in your \
         coordinator and assert all job-0 tasks are handed out before job-1's"
    );
}

/// TODO(you): docs/fault-tolerance (Worker crashes) — killing a worker after
/// its map tasks completed must re-run those maps (output lived in its
/// memory). Mirrors the crash test family.
#[test]
#[ignore]
fn todo_crashed_worker_maps_rerun() {
    unimplemented!(
        "spawn 2 workers, submit a job, kill worker 1 after the map stage, \
         assert the job still completes and the output is correct"
    );
}

/// TODO(you): docs/fault-tolerance (Job failures) — error messages from map/
/// reduce functions must reach PollJobReply.errors verbatim.
#[test]
#[ignore]
fn todo_error_message_preserved() {
    unimplemented!(
        "submit a job against a missing input file; poll until failed=true; \
         assert the worker's error string appears in the poll output"
    );
}

fn tempdir() -> String {
    let dir = std::env::temp_dir().join(format!("mr-rs-test-{}", std::process::id()));
    let _ = std::fs::remove_dir_all(&dir);
    std::fs::create_dir_all(&dir).expect("create temp output dir");
    dir.to_string_lossy().into_owned()
}
