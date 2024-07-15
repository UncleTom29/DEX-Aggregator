// ignition/modules/multiswap.js

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("MultiProtocolSwap", (m) => {
   
  // Deploy the MultiProtocolSwap contract
  const multiswap = m.contract("MultiProtocolSwap");

  return {
    multiswap,
  };
});
