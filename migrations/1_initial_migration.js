const Migrations = artifacts.require("Migrations");
const MinimalHybridContract = artifacts.require("MinimalHybridContract");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(MinimalHybridContract);
};
