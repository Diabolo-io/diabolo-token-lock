# Diabolo Token Lock

Time locks tokens according to an unlock schedule and address.

### Constructor

| Variable | Type | Description |
| ------ | ------ | ------ |
| name | string | The name of this token lock contract.
| token | address | The token address this contract will lock.
| unlockBegin | uint256 | The time at which unlocking of tokens will begin.
| unlockCliff | uint256 | The first time at which tokens are claimable.
| unlockEnd | uint256 | The time at which the last token will unlock.

The constructor set :

 - The name of this token lock contract : "name" (string)
 - The address of the token contract to be locked : "token" (address)
 - The time at which unlocking of tokens will begin : "unlockBegin" (timestamp)
 - The first time at which tokens are claimable : "unlockCliff" (timestamp)
 - The time at which the last token will unlock : "unlockEnd" (timestamp)

### Read Contract

##### claimableAmounts(address)

This call returns the claimable amounts of an address.

##### claimedAmounts(address)

This call returns the claimed amounts by an address.

##### lockedAmounts(address)

This call returns the amounts locked for an address.

##### lockedAddress(uint256)

This call returns the address of an index.

##### lockedAddressExist(address)

This call returns if address exist on lockedAddress.

##### lockedAddresses()

This call returns all registered addresses.

##### totalLockedAddresses()

This call returns the total the total of locked addresses.

##### totalClaimableAmount()

This call returns the total tokens claimable by all addresses.

##### totalClaimedAmount()

This call returns the total of tokens claimed by all addresses.

##### totalLockedAmount()

This call returns the total of tokens locked by all addresses.

##### name()

This call returns the name of contract.

##### token()

This call returns the contract address of the token.

##### unlockBegin()

This call returns the time at which unlocking of tokens will begin.

##### unlockCliff()

This call returns the first time at which tokens are claimable.

##### unlockEnd()

This call returns the time at which the last token will unlock.

### Write Contract

##### lock(amount)

This function locks a token amount. (You must approve the token lock contract address to use the amount)

##### lockFor(address, amount)

This function locks a token amount for an address. (You must approve the token lock contract address to use the amount)

##### claim(address, amount)

This function claims a claimable token amount by the sender and sends it to an address.

##### claimFor(address, amount)

This function claims a claimable token amount by the address and sends it to it.
