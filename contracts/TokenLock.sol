// SPDX-License-Identifier: GNU
pragma solidity ^0.8.11;

/**
 * @dev ERC20 Standard Token interface
 */
interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
}

/**
 * @dev Time-locks tokens according to an unlock schedule and address.
 */
contract TokenLock {
    string public name;
    IERC20 public immutable token;
    uint256 public immutable unlockBegin;
    uint256 public immutable unlockCliff;
    uint256 public immutable unlockEnd;

    address[] public lockedAddress;

    mapping(address=>bool) public lockedAddressExist;
    mapping(address=>uint256) public lockedAmounts;
    mapping(address=>uint256) public claimedAmounts;

    event Locked(address indexed sender, address indexed recipient, uint256 amount);
    event Claimed(address indexed sender, address indexed owner, address indexed recipient, uint256 amount);

    /**
     * @dev Constructor.
     * @param _name The name of this token lock contract.
     * @param _token The token this contract will lock.
     * @param _unlockBegin The time at which unlocking of tokens will begin.
     * @param _unlockCliff The first time at which tokens are claimable.
     * @param _unlockEnd The time at which the last token will unlock.
     */
    constructor(string memory _name, IERC20 _token, uint256 _unlockBegin, uint256 _unlockCliff, uint256 _unlockEnd) {
        require(_unlockBegin >= block.timestamp, "ERC20Locked: Unlock must begin in the future");
        require(_unlockCliff >= _unlockBegin, "ERC20Locked: Unlock cliff must not be before unlock begin");
        require(_unlockEnd >= _unlockCliff, "ERC20Locked: Unlock end must not be before unlock cliff");
        name = _name;
        token = _token;
        unlockBegin = _unlockBegin;
        unlockCliff = _unlockCliff;
        unlockEnd = _unlockEnd;
    }

    /**
     * @dev Returns the maximum number of tokens currently claimable by `owner`.
     * @param owner The account to check the claimable amounts of.
     * @return The number of tokens currently claimable.
     */
    function claimableAmounts(address owner) public view returns(uint256) {
        if(block.timestamp < unlockCliff) {
            return 0;
        }
        uint256 locked = lockedAmounts[owner];
        uint256 claimed = claimedAmounts[owner];
        if(block.timestamp >= unlockEnd) {
            return locked - claimed;
        }
        return (locked * (block.timestamp - unlockBegin)) / (unlockEnd - unlockBegin) - claimed;
    }

    /**
     * @dev Returns total locked amount for all addresses in lockedAddress.
     * @return The total number of tokens locked by all addresses.
     */
    function totalLockedAmount() external view returns(uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < lockedAddress.length; i++) {
            total += lockedAmounts[lockedAddress[i]];
        }
        return total;
    }

    /**
     * @dev Returns total claimed amount for all addresses in lockedAddress.
     * @return The total number of tokens claimed by all addresses.
     */
    function totalClaimedAmount() external view returns(uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < lockedAddress.length; i++) {
            total += claimedAmounts[lockedAddress[i]];
        }
        return total;
    }

    /**
     * @dev Returns total claimable amount for all addresses in lockedAddress.
     * @return The total number of tokens claimable by all addresses.
     */
    function totalClaimableAmount() external view returns(uint256) {
        uint256 total = 0;
        for (uint256 i = 0; i < lockedAddress.length; i++) {
            total += claimableAmounts(lockedAddress[i]);
        }
        return total;
    }

    /**
     * @dev Returns the total of locked addresses.
     * @return The total number of locked addresses.
     */
    function totalLockedAddresses() external view returns (uint256) {
        return lockedAddress.length;
    }

    /**
     * @dev Returns all locked addresses.
     * @return All locked addresses.
     */
    function lockedAddresses() external view returns (address[] memory) {
        return lockedAddress;
    }

    /**
     * @dev Transfers tokens from the caller to the token lock contract and locks them.
     *      Requires that the caller has authorised this contract with the token contract.
     * @param amount The number of tokens to transfer and lock.
     */
    function lock(uint256 amount) external {
        require(block.timestamp < unlockEnd, "TokenLock: Unlock period already complete");
        if(!lockedAddressExist[msg.sender]){
            lockedAddress.push(msg.sender);
            lockedAddressExist[msg.sender] = true;
        }
        lockedAmounts[msg.sender] += amount;
        require(token.transferFrom(msg.sender, address(this), amount), "TokenLock: Transfer failed");
        emit Locked(msg.sender, msg.sender, amount);
    }

    /**
     * @dev Transfers tokens from the caller to the token lock contract and locks them for benefit of `recipient`.
     *      Requires that the caller has authorised this contract with the token contract.
     * @param recipient The account the tokens will be claimable by.
     * @param amount The number of tokens to transfer and lock.
     */
    function lockFor(address recipient, uint256 amount) external {
        require(block.timestamp < unlockEnd, "TokenLock: Unlock period already complete");
        if(!lockedAddressExist[recipient]){
            lockedAddress.push(recipient);
            lockedAddressExist[recipient] = true;
        }
        lockedAmounts[recipient] += amount;
        require(token.transferFrom(msg.sender, address(this), amount), "TokenLock: Transfer failed");
        emit Locked(msg.sender, recipient, amount);
    }

    /**
     * @dev Claims the caller's tokens that have been unlocked, sending them to `recipient`.
     * @param recipient The account to transfer unlocked tokens to.
     * @param amount The amount to transfer. If greater than the claimable amount, the maximum is transferred.
     */
    function claim(address recipient, uint256 amount) external {
        uint256 claimable = claimableAmounts(msg.sender);
        if(amount > claimable) {
            amount = claimable;
        }
        claimedAmounts[msg.sender] += amount;
        require(token.transfer(recipient, amount), "TokenLock: Transfer failed");
        emit Claimed(msg.sender, msg.sender, recipient, amount);
    }

    /**
     * @dev Claims the owner's tokens that have been unlocked.
     * @param owner The account with unlocked tokens to claim.
     * @param amount The amount to transfer. If greater than the claimable amount, the maximum is transferred.
     */
    function claimFor(address owner, uint256 amount) external {
        uint256 claimable = claimableAmounts(owner);
        if(amount > claimable) {
            amount = claimable;
        }
        claimedAmounts[owner] += amount;
        require(token.transfer(owner, amount), "TokenLock: Transfer failed");
        emit Claimed(msg.sender, owner, owner, amount);
    }
}
