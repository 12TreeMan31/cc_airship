use miniserde::{Deserialize, Serialize, json};
use std::fs;

static mut SEARCH_DIR: Option<String> = None;
const CONFIG_PATH: &str = "./flash.conf";

#[derive(Deserialize)]
struct DownloadRequest {
    file: String,
}

#[derive(Serialize)]
struct QueryResponse {
    status: String,
    cause: Option<String>,
    files: Option<Vec<String>>,
}

#[derive(Serialize)]
struct DownloadResponse {
    status: String,
    cause: Option<String>,
    text: Option<String>,
}

fn safe_read() -> String {
    //unsafe { SEARCH_DIR.clone().expect("Wont fail") }

    unimplemented!()
}

pub fn read_conf() {
    let raw = match fs::read_to_string(CONFIG_PATH) {
        Ok(s) => s,
        Err(_) => "search_dir=./flash-files".to_string(),
    };

    let pairs = raw
        .lines()
        .filter_map(|x| x.split_once("="))
        .map(|(s, x)| (s.trim(), x.trim()));

    for (key, val) in pairs {
        match key {
            "search_dir" => unsafe { SEARCH_DIR = Some(val.to_string()) },
            _ => {}
        }
    }
}

pub fn query() -> String {
    /*let dir: Vec<String> = fs::read_dir(safe_read())
        .unwrap()
        .map(|v| v.expect(msg))
        .collect();

    let res = QueryResponse {
        status: "ok",
        cause: None,
        files
    }*/

    unimplemented!()
}

pub fn download(input: &str) -> String {
    unimplemented!()
}
