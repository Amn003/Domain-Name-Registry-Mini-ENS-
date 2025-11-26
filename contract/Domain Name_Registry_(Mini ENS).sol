// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DomainNameRegistry {
    struct Domain {
        address owner;
        uint256 expiresAt;
    }

    mapping(string => Domain) public domains;

    uint256 public constant REGISTRATION_DURATION = 365 days;

    /// Register a domain name if available or expired
    function register(string calldata name) external payable {
        require(bytes(name).length > 0, "Name required");

        Domain storage domain = domains[name];

        require(
            domain.owner == address(0) || domain.expiresAt < block.timestamp,
            "Domain not available"
        );

        domains[name] = Domain({
            owner: msg.sender,
            expiresAt: block.timestamp + REGISTRATION_DURATION
        });
    }

    /// Renew an existing domain before or after expiration
    function renew(string calldata name) external payable {
        Domain storage domain = domains[name];

        require(domain.owner != address(0), "Domain not registered");
        require(domain.owner == msg.sender, "Not domain owner");

        domain.expiresAt += REGISTRATION_DURATION;
    }

    /// Transfer domain to another user
    function transfer(string calldata name, address newOwner) external {
        Domain storage domain = domains[name];

        require(domain.owner == msg.sender, "Not domain owner");
        require(newOwner != address(0), "Invalid new owner");

        domain.owner = newOwner;
    }

    /// Helper view: check availability
    function isAvailable(string calldata name) external view returns (bool) {
        return domains[name].expiresAt < block.timestamp;
    }
}
