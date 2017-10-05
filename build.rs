extern crate build_helper;
extern crate pnet_macros;
extern crate syntex;

use std::env;
use std::path::Path;
use std::fs;

use build_helper::{target, Endianness};

const FILES: &'static [&'static str] = &["netlink.rs", "route/route.rs", "audit/audit.rs"];

pub fn expand() {
    let out_dir = env::var_os("OUT_DIR").unwrap();

    let target_endian = target::endian().unwrap_or(Endianness::Little);
    let endian_ext = if target_endian == Endianness::Little {
        ".le"
    } else {
        ".be"
    };

    for file in FILES {
        let src_file = format!("src/packet/{}.in", file);
        let src_file_endian = format!("{}{}", src_file, endian_ext);
        let src = Path::new(&src_file_endian);

        let src = if src.exists() {
            src
        } else {
            Path::new(&src_file)
        };

        let dst_name = Path::new(file);
        if let Some(parent) = dst_name.parent() {
            fs::create_dir(Path::new(&out_dir).join(parent));
        }
        let dst = Path::new(&out_dir).join(dst_name);

        let mut registry = syntex::Registry::new();
        pnet_macros::register(&mut registry);

        registry.expand("", &src, &dst).unwrap();
    }
}

fn main() {
    expand();
}
