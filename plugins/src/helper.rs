/// Some extra stuff to make generating plugins require less boilerplate
use crate::ffi::{
    PluginString, PluginStringKind_PLUGIN_STRING_OWNED, PluginStringKind_PLUGIN_STRING_STATIC,
};
use std::ffi::CString;

#[macro_export]
macro_rules! plugin_fn {
    ($name:ident, $func:path) => {
        unsafe extern "C" fn $name(s: *const i8) -> PluginString {
            let raw = match unsafe { ::std::ffi::CStr::from_ptr(s).to_str() } {
                Ok(raw) => raw,
                Err(e) => return PluginString::from_string(&e.to_string()),
            };

            let json = $func(raw);

            PluginString::from_string(&json)
        }
    };
}

pub unsafe extern "C" fn free_string(s: PluginString) {
    if s.kind == PluginStringKind_PLUGIN_STRING_STATIC {
        return;
    }

    drop(unsafe { Box::from_raw(s.data) });
}

impl PluginString {
    pub fn from_string(s: &str) -> Self {
        let Ok(c_str) = CString::new(s) else {
            unreachable!();
        };

        let ptr = c_str.into_boxed_c_str();

        Self {
            data: ptr.as_ptr() as *mut _,
            kind: PluginStringKind_PLUGIN_STRING_OWNED,
        }
    }
    pub fn from_str(s: &'static str) -> Self {
        unimplemented!()
    }
}
