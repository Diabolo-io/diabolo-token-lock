# Diabolo Token Lock

Time locks tokens according to an unlock schedule and address.

### Variable

| Variable | Type | Description |
| ------ | ------ | ------ |
| token | address | The token address this contract will lock.
| unlockBegin | uint256 | The time at which unlocking of tokens will begin.
| unlockCliff | uint256 | The first time at which tokens are claimable.
| unlockEnd | uint256 | The time at which the last token will unlock.

### Constructor

The constructor set :

 - The address of the token contract to be locked : "token" (address)
 - The time at which unlocking of tokens will begin : "unlockBegin" (timestamp)
 - The first time at which tokens are claimable : "unlockCliff" (timestamp)
 - The time at which the last token will unlock : "unlockEnd" (timestamp)

### Functions

##### claimableBalance(address)

This function returns the claimable balance of an address.

##### claimedAmounts(address)

This function returns the claimed amounts by an address.

##### lockedAmounts(address)

This function returns the amounts locked for an address.

##### lock(address, amount)

This function locks a token amount for an address. (You must approve the token lock contract address to use the amount)

##### claim(address, amount)

This function claims an amount of token claimable by an address.
