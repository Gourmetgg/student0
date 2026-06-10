//! Shared helpers for integration tests. Black-box only: spawns the built
//! server binary and talks raw TCP, so this file always compiles against the
//! pristine starter.

use std::io::{Read, Write};
use std::net::TcpStream;
use std::process::{Child, Command};
use std::time::{Duration, Instant};

/// Kills the spawned server when the test ends (pass or fail).
pub struct ServerGuard {
    child: Child,
    pub port: u16,
}

impl Drop for ServerGuard {
    fn drop(&mut self) {
        let _ = self.child.kill();
        let _ = self.child.wait();
    }
}

/// Pick a port that is currently free (best effort).
pub fn pick_port() -> u16 {
    let l = std::net::TcpListener::bind("127.0.0.1:0").expect("bind :0");
    l.local_addr().unwrap().port()
}

/// Spawn the server binary with `--files <dir> --port <port>` and wait for
/// it to accept connections.
pub fn start_server(files_dir: &str) -> ServerGuard {
    let port = pick_port();
    let child = Command::new(env!("CARGO_BIN_EXE_http_server_rs"))
        .args(["--files", files_dir, "--port", &port.to_string()])
        .spawn()
        .expect("failed to spawn http_server_rs");
    let guard = ServerGuard { child, port };
    wait_tcp(port, Duration::from_secs(5));
    guard
}

pub fn wait_tcp(port: u16, budget: Duration) {
    let start = Instant::now();
    while start.elapsed() < budget {
        if TcpStream::connect(("127.0.0.1", port)).is_ok() {
            return;
        }
        std::thread::sleep(Duration::from_millis(50));
    }
    panic!("nothing listening on 127.0.0.1:{port} after {budget:?}");
}

/// Issue one HTTP/1.0 GET and return the raw response bytes.
pub fn http_get(port: u16, path: &str) -> Vec<u8> {
    let mut s = TcpStream::connect(("127.0.0.1", port)).expect("connect");
    s.set_read_timeout(Some(Duration::from_secs(5))).unwrap();
    write!(s, "GET {path} HTTP/1.0\r\n\r\n").expect("send request");
    let mut buf = Vec::new();
    let _ = s.read_to_end(&mut buf);
    buf
}

/// Split a raw response into (status_line, headers, body).
pub fn split_response(raw: &[u8]) -> (String, String, Vec<u8>) {
    let sep = raw
        .windows(4)
        .position(|w| w == b"\r\n\r\n")
        .expect("response has no header/body separator");
    let head = String::from_utf8_lossy(&raw[..sep]).to_string();
    let body = raw[sep + 4..].to_vec();
    let (status, headers) = head.split_once("\r\n").unwrap_or((head.as_str(), ""));
    (status.to_string(), headers.to_string(), body)
}
