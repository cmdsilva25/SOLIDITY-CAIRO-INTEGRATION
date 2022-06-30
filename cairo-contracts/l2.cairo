%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_nn, assert_not_zero
from starkware.starknet.common.messages import send_message_to_l1
from starkware.cairo.common.uint256 import (
   Uint256,
   uint256_check,
   uint256_le,
   uint256_sub,
   uint256_mul,
)

# Storage variable to play with
@storage_var
func var() -> (res : Uint256):
end

@storage_var
func l1_contract_address() -> (res : felt):
end

######################################################
## get_l1_contract_address
######################################################
@view
func get_l1_contract_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (var : felt):
   let (res) = l1_contract_address.read()
   return (res)
end

######################################################
## set_l1_contract_address
######################################################
@external
func set_l1_contract_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}( _address : felt ):
   l1_contract_address.write( _address )
   return()
end

######################################################
## get_var
######################################################
@view
func get_var{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (var : Uint256):
   let (res) = var.read()
   return (res)
end

######################################################
## set_var
######################################################
@external
func set_var{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}( _var : Uint256 ):
   var.write( _var )
   return()
end

######################################################
## l1_handler_receive_var
######################################################
@l1_handler
func l1_handler_receive_var{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
   from_address : felt,
   l1_var_low : felt,
   l1_var_high : felt,
):
   alloc_locals
   let l1_var= Uint256(low=l1_var_low, high=l1_var_high)
   var.write(l1_var)
   return ()
end


######################################################
## send_var_to_l2
######################################################
@external
func send_var_to_l2{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}( amount : Uint256 ):
    # l1_contract_address must be set
    let (l1_address) = l1_contract_address.read()
    assert_not_zero( l1_address )

    let (res) = var.read()

    # send msg for updating the L1 storage variable
    let (message_payload : felt*) = alloc()
    assert message_payload[0] = res.low
    assert message_payload[1] = res.high
    send_message_to_l1( to_address=l1_address, payload_size=2, payload=message_payload )

    return ()
end