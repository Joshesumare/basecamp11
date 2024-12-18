#[starknet::interface]
pub trait ICounter<TContractState> {
    fn Consultar(self: @TContractState) -> u32;
    fn Sumar_uno(ref self: TContractState);
    fn Restar_uno(ref self: TContractState);
    fn Restablecer(ref self: TContractState);
}


#[starknet::contract]
mod Counter {
    use super::ICounter;
    use openzeppelin_access::ownable::OwnableComponent;
    use starknet::ContractAddress;
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    //Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableTwoStep = OwnableComponent::OwnableTwoStepImpl<ContractState>;
    impl InternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        counter: u32,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        CounterIncreased: CounterIncreased,
        CounterDecreased: CounterDecreased,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterIncreased {
        counter: u32,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterDecreased {
        counter: u32,
    }

    #[constructor]
    fn constructor(ref self: ContractState, init_value: u32, owner: ContractAddress) {
        self.counter.write(init_value);
        self.ownable.initializer(owner);
    }


    #[abi(embed_v0)]
    impl CounterImpl of ICounter<ContractState> {
        fn Consultar(self: @ContractState) -> u32 {
            self.counter.read()
        }

        fn Sumar_uno(ref self: ContractState) {
            let old_counter = self.counter.read();
            let new_counter = old_counter + 1;
            self.counter.write(new_counter);
            self.emit(CounterIncreased { counter: new_counter });
        }

        fn Restar_uno(ref self: ContractState) {
            let old_counter = self.counter.read();
            assert(old_counter > 0, 'ya valgo 0');
                let new_counter = old_counter - 1;
                self.counter.write(new_counter);
                self.emit(CounterDecreased { counter: new_counter });
        }

        fn Restablecer(ref self: ContractState) {
            self.ownable.assert_only_owner(); // solo el Owner del contrato puede llamar esta funcion 
            self.counter.write(0);
        }
    }
}
