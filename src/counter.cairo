#[starknet::contract]
pub mod counter_contract {
    #[storage]
    struct Storage {
        pub counter: u32,
    }
}