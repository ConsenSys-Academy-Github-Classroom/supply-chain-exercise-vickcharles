module.exports = {
  networks: {
    local: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*", // Match any network id
    },
  },
  compilers: {
    solc: {
      version: "^0.8.8", // Fetch latest 0.8.x Solidity compiler
    },
  },
};
