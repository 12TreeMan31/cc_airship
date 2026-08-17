use abi::ffi::*;
use abi::helper::*;

mod flash;

abi::plugin_fn!(download, flash::download);
abi::plugin_fn!(query, flash::query);

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
    fn_count: FUNCTIONS.len() as u64,
    fns: FUNCTIONS.as_ptr() as *mut _,
    string_free: Some(free_string),
};

#[unsafe(no_mangle)]
pub extern "C" fn plg_endpoints() -> *const PluginInfo {
    &INFO.into()
}
