const Migrations = artifacts.require("Migrations");
const MinimumHybridContract = artifacts.require("MinimumHybridContract");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(MinimumHybridContract);
};
