use crate::ffi::{
    PluginString, PluginStringKind_PLUGIN_STRING_OWNED, PluginStringKind_PLUGIN_STRING_STATIC,
};
use std::ffi::CString;

pub unsafe extern "C" fn free_string(s: PluginString) {
    if s.kind == PluginStringKind_PLUGIN_STRING_STATIC {
        return;
    }

    drop(unsafe { Box::from_raw(s.data) });
}

impl PluginString {
    pub fn from_string(s: &str) -> Self {
        let c_str = CString::new(s).expect("Wont fail");

        unimplemented!()
    }

    pub fn from_str(s: &'static str) -> Self {
        unimplemented!()
    }
}
