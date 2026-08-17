use miniserde::{Serialize, json};
use std::fs;
use std::sync::LazyLock;

static SEARCH_DIR: LazyLock<String> = LazyLock::new(|| "flash-files".to_string());

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

fn get_search_dir() -> &'static str {
    unsafe { &SEARCH_DIR }
}

/* pub fn read_conf() {
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
} */

pub fn query(_: &str) -> String {
    let Ok(dir) = fs::read_dir(get_search_dir()) else {
        return "err".to_string();
    };

    let listing: Vec<String> = dir
        .filter_map(|v| match v {
            Ok(v) => Some(v.file_name()),
            Err(_) => None,
        })
        .map(|s| s.to_str().unwrap().to_string())
        .collect();

    let res = QueryResponse {
        status: "ok".to_string(),
        cause: None,
        files: Some(listing),
    };

    json::to_string(&res)
}

/// Takes a file name as input and outputs a serialized `DownloadResponse`
pub fn download(file: &str) -> String {
    let path = format!("{}/{}", get_search_dir(), file);

    let res = match fs::read_to_string(path) {
        Ok(s) => DownloadResponse {
            status: "ok".to_string(),
            cause: None,
            text: Some(s),
        },
        Err(e) => DownloadResponse {
            status: "error".to_string(),
            cause: Some(e.to_string()),
            text: None,
        },
    };

    json::to_string(&res)
}
