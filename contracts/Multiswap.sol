// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

library TransferHelper {
    function safeTransfer(address token, address to, uint256 value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20(token).transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract MultiProtocolSwap {
    struct SwapStep {
        address pool;
        bytes data;
        uint amountIn;
        uint amountOutMin;
        uint deadline;
    }

    struct SwapPath {
        address tokenIn;
        uint amountIn;
        SwapStep[] steps;
    }

    struct SwapData {
        uint8 protocol; // Protocol identifier
        bytes data; // Encoded swap data
    }

    event SwapExecuted(address indexed user, uint amountOut, uint timestamp);

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "Transaction expired");
        _;
    }

    function multiswap(
        SwapPath[] calldata paths,
        uint deadline
    ) external ensure(deadline) {
        for (uint i = 0; i < paths.length; i++) {
            address tokenIn = paths[i].tokenIn;
            uint amountIn = paths[i].amountIn;
            
            for (uint j = 0; j < paths[i].steps.length; j++) {
                SwapStep memory step = paths[i].steps[j];
                address pool = step.pool;
                bytes memory data = step.data;
                uint amountOutMin = step.amountOutMin;

                
                // Transfer tokens to the pool
                TransferHelper.safeTransfer(tokenIn, pool, amountIn);

                // Call the pool's swap function
                (bool success, bytes memory returnData) = pool.call(data);
                require(success, "Swap failed");

                // Decode the output amount
                uint amountOut = abi.decode(returnData, (uint));
                require(amountOut >= amountOutMin, "Insufficient output amount");

                // Update tokenIn and amountIn for the next step
                tokenIn = address(uint160(uint256(keccak256(abi.encodePacked(tokenIn, amountIn, pool, amountOut)))));
                amountIn = amountOut;
            }

            emit SwapExecuted(msg.sender, amountIn, block.timestamp);
        }
    }
}
