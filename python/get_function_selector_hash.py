import sys
from starkware.starknet.compiler.compile import get_selector_from_name

def main():
    if len(sys.argv)==1:
        print ('specify the function name as input parameter')
        exit(1)
    
    print( get_selector_from_name( sys.argv[1] ) )

main()