use pnet_macros_support::types::*;
use pnet::packet::PrimitiveValues;
use packet::route::link::{IfFlags,IfType};
use packet::route::addr::{IfAddrFlags,Scope};
use packet::route::neighbour::{NeighbourFlags,NeighbourState};

#[packet]
pub struct IfInfo {
    family: u8,
    _pad: u8,
    #[construct_with(u16be)]
    type_: IfType,
    index: u32be,
    #[construct_with(u32be)]
    flags: IfFlags,
    change: u32be,
    #[payload]
    payload: Vec<u8>
}

impl PrimitiveValues for IfFlags {
    type T = (u32,);
    fn to_primitive_values(&self) -> (u32,) {
        (self.bits(),)
    }
}

impl PrimitiveValues for IfType {
    type T = (u16,);
    fn to_primitive_values(&self) -> (u16,) {
        use std::mem;
        unsafe { (mem::transmute(*self),) }
    }
}

impl PrimitiveValues for Scope {
    type T = (u8,);
    fn to_primitive_values(&self) -> (u8,) {
        use std::mem;
        unsafe { (mem::transmute(*self),) }
    }
}

impl PrimitiveValues for IfAddrFlags {
    type T = (u8,);
    fn to_primitive_values(&self) -> (u8,) {
        (self.bits(),)
    }
}

#[packet]
pub struct IfAddr {
    family: u8,
    prefix_len: u8,
    #[construct_with(u8)]
    flags: IfAddrFlags,
    #[construct_with(u8)]
    scope: Scope,
    index: u32be,
    #[payload]
    payload: Vec<u8>
}

/* IfAddr cache_info struct */
#[packet]
pub struct IfAddrCacheInfo {
    ifa_prefered: u32be,
    ifa_valid: u32be,
    created: u32be, /* created timestamp, hundredths of seconds */
    updated: u32be, /* updated timestamp, hundredths of seconds */
    #[payload]
    #[length="0"]
    payload: Vec<u8>,
}

#[packet]
pub struct NeighbourDiscovery {
    family: u8,
    pad1: u8,
    pad2: u16be,
    ifindex: u32be, // Should be i32le, not implemented?
    #[construct_with(u16be)]
    state: NeighbourState,
    #[construct_with(u8)]
    flags: NeighbourFlags,
    type_: u8,
    #[payload]
    payload: Vec<u8>,
}

impl PrimitiveValues for NeighbourFlags {
    type T = (u8,);
    fn to_primitive_values(&self) -> (u8,) {
        (self.bits(),)
    }
}

impl PrimitiveValues for NeighbourState {
    type T = (u16,);
    fn to_primitive_values(&self) -> (u16,) {
        (self.bits(),)
    }
}

#[packet]
pub struct RtMsg {
    rtm_family: u8,
    rtm_dst_len: u8,
    rtm_src_len: u8,
    rtm_tos: u8,

    rtm_table: u8, /* Routing table id */
    rtm_protocol: u8, /* Routing protocol */
    #[construct_with(u8)]
    rtm_scope: Scope,

    rtm_flags: u32be,
    _padding: u8,
    #[payload]
    payload: Vec<u8>,
}

/* rta_cacheinfo: linux/rtnetlink.h */
#[packet]
pub struct RouteCacheInfo {
    rta_clntref: u32be,
    rta_lastuse: u32be,
    rta_expires: u32be,
    rta_error: u32be,
    rta_used: u32be,
    rta_id: u32be,
    rta_ts: u32be,
    rta_tsusage: u32be,
    #[payload]
    #[length="0"]
    payload: Vec<u8>,
}

#[packet]
pub struct FibRule {
    family: u8,
    dst_len: u8,
    src_len: u8,
    tos: u8,

    table: u8,
    res1: u8,
    res2: u8,
    action: u8,

    flags: u32le,
    #[payload]
    payload: Vec<u8>,
}

#[packet]
pub struct RtAttr {
    rta_len: u16be,
    rta_type: u16be,
    #[payload]
    #[length_fn = "rtattr_len"]
    payload: Vec<u8>,
}

fn rtattr_len(pkt: &RtAttrPacket) -> usize {
    pkt.get_rta_len() as usize - 4
}

#[packet]
pub struct RtAttrMtu {
    rta_len: u16be,
    rta_type: u16be,
    mtu: u32be,
    #[payload]
    #[length = "0"]
    _payload: Vec<u8>,
}
