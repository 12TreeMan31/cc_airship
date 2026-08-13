use abi::ffi::*;
use abi::helper::*;
use std::ffi::{CStr, CString};

mod flash;

unsafe extern "C" fn download(s: *const i8) -> PluginString {
    let c_string = CStr::from_ptr(s).to_str().expect("Invalid string");
    let res = flash::download(c_string);
    unimplemented!()
}

unsafe extern "C" fn query(_: *const i8) -> PluginString {
    unimplemented!()
}

const FUNCTIONS: [PluginFunction; 2] = [
    PluginFunction {
        name: c"download".as_ptr(),
        function: Some(download),
    },
    PluginFunction {
        name: c"query".as_ptr(),
        function: Some(query),
    },
];

const INFO: PluginInfo = PluginInfo {
    plugin_name: c"flash".as_ptr() as *mut _,
    version: 1,
    fn_count: 2,
    fns: FUNCTIONS.as_ptr() as *mut _,
    string_free: Some(free_string),
};

#[unsafe(no_mangle)]
pub extern "C" fn plg_endpoints() -> *const PluginInfo {
    flash::read_conf();
    &INFO.into()
}
