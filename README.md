# DEX-Aggregator
This calldata design allows for flexible integration of multiple liquidity venues, enabling complex routing and multi-protocol swaps.

SwapStep Struct: Holds data for each swap step, including the pool address, encoded data, amount in, minimum amount out, and deadline.

SwapPath Struct: Represents the overall swap path, containing the input token, initial amount, and an array of swap steps.

multiswap Function: Iterates through the swap paths and steps, transferring tokens and calling the respective swap functions.

JavaScript Encoding: Prepare the calldata for each swap step and calls the multiswap function.
