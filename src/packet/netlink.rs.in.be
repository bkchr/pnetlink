use pnet_macros_support::types::*;
use pnet::packet::PrimitiveValues;

#[packet]
pub struct Netlink {
    length: u32be,
    kind: u16be, // NOOP | ERROR | DONE | OVERRUN
    #[construct_with(u16be)] flags: NetlinkMsgFlags,
    seq: u32be,
    pid: u32be,
    #[payload]
    #[length_fn = "payload_length"]
    payload: Vec<u8>,
}

#[packet]
pub struct NetlinkError {
    error: u32be, // must be i32le
    #[payload] payload: Vec<u8>,
}

impl PrimitiveValues for NetlinkMsgFlags {
    type T = (u16,);
    fn to_primitive_values(&self) -> (u16,) {
        (self.bits(),)
    }
}

fn payload_length(pkt: &NetlinkPacket) -> usize {
    pkt.get_length() as usize - 16
}
