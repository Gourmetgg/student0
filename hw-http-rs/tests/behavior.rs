//! Black-box behavior tests for the Fall 2025 hw-http-rs tasks.
//!
//! Every test is `#[ignore]`d so the pristine starter still compiles and
//! `cargo test` stays green until you opt in:
//!
//!     cargo test --test behavior -- --ignored          # run all of them
//!     cargo test --test behavior serve_index -- --ignored
//!
//! Or via the framework: `RUN_FULL=1 bash tests/run.sh`.
//! Each test cites the handout page it checks (Fall 2025 snapshots).

mod common;

use common::{http_get, split_response, start_server};

/// docs/requests (Serving files): 200 + Content-Length + exact body.
#[test]
#[ignore]
fn serve_index_200_with_length() {
    let srv = start_server("www");
    let raw = http_get(srv.port, "/index.html");
    let (status, headers, body) = split_response(&raw);
    assert!(status.contains("200"), "status line: {status}");
    let disk = std::fs::read("www/index.html").expect("read www/index.html");
    let want = format!("Content-Length: {}", disk.len());
    assert!(
        headers.to_lowercase().contains(&want.to_lowercase()),
        "missing/incorrect Content-Length (want '{want}'):\n{headers}"
    );
    assert_eq!(body, disk, "body must match the file byte-for-byte");
}

/// docs/requests (Serving files): Content-Type from the file extension.
#[test]
#[ignore]
fn mime_type_from_extension() {
    let srv = start_server("www");
    let raw = http_get(srv.port, "/index.html");
    let (_, headers, _) = split_response(&raw);
    assert!(
        headers.to_lowercase().contains("content-type: text/html"),
        "expected Content-Type: text/html for .html:\n{headers}"
    );
}

/// docs/requests (Serving files): missing file → 404 Not Found.
#[test]
#[ignore]
fn missing_file_404() {
    let srv = start_server("www");
    let raw = http_get(srv.port, "/definitely-not-here.txt");
    let (status, _, _) = split_response(&raw);
    assert!(status.contains("404"), "status line: {status}");
}

/// docs/requests (Serving directories): / serves the directory's index.html.
#[test]
#[ignore]
fn root_serves_index_html() {
    let srv = start_server("www");
    let raw = http_get(srv.port, "/");
    let (status, _, body) = split_response(&raw);
    assert!(status.contains("200"), "status line: {status}");
    let disk = std::fs::read("www/index.html").unwrap();
    assert_eq!(body, disk, "GET / must return index.html contents");
}

/// docs/requests (Serving directories): index-less directory → listing with
/// child links and a parent link.
#[test]
#[ignore]
fn dir_listing_has_children_and_parent_link() {
    let srv = start_server("www");
    let raw = http_get(srv.port, "/my_documents");
    let (status, _, body) = split_response(&raw);
    let body = String::from_utf8_lossy(&body);
    assert!(status.contains("200"), "status line: {status}");
    assert!(body.contains("href"), "listing should contain links:\n{body}");
    assert!(
        body.contains("..") || body.to_lowercase().contains("parent"),
        "listing must link to the parent directory:\n{body}"
    );
}

/// docs/stats: /stats reports per-status counts (requires Part 4 + wiring).
#[test]
#[ignore]
fn stats_url_reports_counts() {
    let srv = start_server("www");
    let _ = http_get(srv.port, "/index.html"); // one 200
    let _ = http_get(srv.port, "/nope.txt"); // one 404
    let raw = http_get(srv.port, "/stats");
    let (status, _, body) = split_response(&raw);
    let body = String::from_utf8_lossy(&body);
    assert!(status.contains("200"), "GET /stats should succeed: {status}");
    assert!(body.contains("200"), "stats should mention the 200 count:\n{body}");
    assert!(body.contains("404"), "stats should mention the 404 count:\n{body}");
}

/// docs/socket (Handling connections): several concurrent clients all get
/// complete, correct bodies.
#[test]
#[ignore]
fn ten_concurrent_clients() {
    let srv = start_server("www");
    let disk = std::fs::read("www/index.html").unwrap();
    let port = srv.port;
    let handles: Vec<_> = (0..10)
        .map(|_| {
            let want = disk.clone();
            std::thread::spawn(move || {
                let raw = http_get(port, "/index.html");
                let (status, _, body) = split_response(&raw);
                assert!(status.contains("200"));
                assert_eq!(body, want);
            })
        })
        .collect();
    for h in handles {
        h.join().expect("a concurrent client failed");
    }
}

/// TODO(you): docs/requests — "No more than 1024 bytes of the file should be
/// loaded into memory at any given time." Serve a file much larger than RAM
/// would forgive (e.g. generate 200 MB in a tempdir) and watch the server's
/// peak RSS (/proc/<pid>/status VmHWM) stay flat while the body streams.
#[test]
#[ignore]
fn todo_streaming_uses_bounded_memory() {
    unimplemented!("write me: bounded-memory streaming check (see doc comment)");
}

/// TODO(you): docs/requests — "we will be testing that your server does not
/// panic upon an internal error." Send garbage bytes, a request with no
/// blank line, and a huge request line; after each, assert the server still
/// answers a normal GET.
#[test]
#[ignore]
fn todo_no_panic_on_malformed_input() {
    unimplemented!("write me: malformed-input robustness (see doc comment)");
}
