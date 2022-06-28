%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_nn
from starkware.starknet.common.messages import send_message_to_l1
from starkware.cairo.common.uint256 import (
   Uint256,
   uint256_check,
   uint256_le,
   uint256_sub,
   uint256_mul,
)
const L1_CONTRACT_ADDRESS = (0x2Db8c2615db39a5eD8750B87aC8F217485BE11EC)
const MESSAGE_WITHDRAW = 0
 
 
# A mapping from a user (L1 Ethereum address) to their balance.
@storage_var
func var() -> (res : Uint256):
end
 
@view
func get_var{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (var : Uint256):
   let (res) = var.read()
   return (res)
end
 
@l1_handler
func handle_deposit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
   from_address : felt,
   l1_var_low : felt,
   l1_var_high : felt,
):
   alloc_locals
 
   let l1_var= Uint256(low=l1_var_low, high=l1_var_high)
 
   var.write(l1_var)
 
   return ()
end
