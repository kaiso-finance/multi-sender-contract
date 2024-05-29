// File: @openzeppelin/contracts@5.0.2/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: @openzeppelin/contracts@5.0.2/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts@5.0.2/token/ERC721/IERC721.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.20;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts@5.0.2/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts@5.0.2/utils/Pausable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    bool private _paused;

    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    /**
     * @dev The operation failed because the contract is paused.
     */
    error EnforcedPause();

    /**
     * @dev The operation failed because the contract is not paused.
     */
    error ExpectedPause();

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        if (paused()) {
            revert EnforcedPause();
        }
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        if (!paused()) {
            revert ExpectedPause();
        }
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts@5.0.2/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/KaisoMultiSenderV2.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

contract KaisoMultiSenderV2 is Ownable(msg.sender), Pausable, ReentrancyGuard {
    address public feeAddress;
    uint256 public ratePerAddress;
    uint256 public minimumRatePerTx;
    uint256 public maxTransfersPerTx;

    event TransferMultiSent(address indexed sender, address indexed token, string indexed transferType, uint256 value);
    event TransferFailed(address indexed sender, address indexed token, address indexed to, uint256 value);
    event TokenRecoveryERC20(address indexed token, address indexed recepient, uint256 amount);
    event TokenRecoveryERC721(address indexed token, address indexed recepient, uint256 tokenId);
    event NativeCoinRecovery(address indexed recepient, uint256 amount);

    error TransfersReverted(address recipient, uint256 amount, string revertMessage);

    constructor(address _feeAddress, uint256 _ratePerAddress, uint256 _minimumRatePerTx, uint256 _maxTransfersPerTx) {
        feeAddress = _feeAddress;
        ratePerAddress = _ratePerAddress;
        minimumRatePerTx = _minimumRatePerTx;
        maxTransfersPerTx = _maxTransfersPerTx;
    }

    function transferERC20(
        IERC20 token,
        address[] memory recipients,
        uint256[] memory values,
        bool revertOnFail
    ) external payable nonReentrant whenNotPaused whenFeeSent(recipients.length, values.length) {
        uint256 totalSuccess = 0;
        uint256 totalSent = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            (bool success, bytes memory returnData) = address(token).call(
                abi.encodePacked(token.transferFrom.selector, abi.encode(msg.sender, recipients[i], values[i]))
            );

            if (success) {
                bool transferSuccess = abi.decode(returnData, (bool));
                if (transferSuccess) {
                    totalSuccess++;
                    totalSent = totalSent + values[i];
                } else {
                    if (revertOnFail) {
                        revert TransfersReverted(
                            recipients[i],
                            values[i],
                            'One of the transfers failed. All transfers reverted.'
                        );
                    } else {
                        emit TransferFailed(msg.sender, address(token), recipients[i], values[i]);
                    }
                }
            } else {
                if (revertOnFail) {
                    revert TransfersReverted(
                        recipients[i],
                        values[i],
                        'One of the transfers failed. All transfers reverted.'
                    );
                } else {
                    emit TransferFailed(msg.sender, address(token), recipients[i], values[i]);
                }
            }
        }

        require(totalSuccess > 0, 'All transfers failed');

        payFeeAndGiveChange(totalSuccess, msg.value, 0);
        emit TransferMultiSent(msg.sender, address(token), 'ERC20', totalSent);
    }

    function transferERC721(
        IERC721 token,
        address[] memory recipients,
        uint256[] memory ids,
        bool revertOnFail
    ) external payable nonReentrant whenNotPaused whenFeeSent(recipients.length, ids.length) {
        uint256 totalSuccess = 0;
        uint256 totalSent = 0;

        bytes4 safeTransferFromSelector = bytes4(keccak256('safeTransferFrom(address,address,uint256)'));

        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.ownerOf(ids[i]) == msg.sender, 'NOT OWNED');

            (bool success, ) = address(token).call(
                abi.encodePacked(safeTransferFromSelector, abi.encode(msg.sender, recipients[i], ids[i]))
            );

            if (success) {
                totalSuccess++;
                totalSent = totalSent + 1;
            } else {
                if (revertOnFail) {
                    revert TransfersReverted(
                        recipients[i],
                        ids[i],
                        'One of the transfers failed. All transfers reverted.'
                    );
                } else {
                    emit TransferFailed(msg.sender, address(token), recipients[i], ids[i]);
                }
            }
        }

        require(totalSuccess > 0, 'All transfers failed');

        payFeeAndGiveChange(totalSuccess, msg.value, 0);
        emit TransferMultiSent(msg.sender, address(token), 'ERC721', totalSent);
    }

    function transferNativeCoin(
        address[] memory recipients,
        uint256[] memory values,
        bool revertOnFail
    ) external payable nonReentrant whenNotPaused whenFeeSent(recipients.length, values.length) {
        uint256 totalSuccess = 0;
        uint256 totalSent = 0;
        for (uint256 i = 0; i < recipients.length; i++) {
            (bool success, ) = recipients[i].call{value: values[i], gas: 3500}('');
            if (revertOnFail) require(success, 'One of the transfers failed');
            else if (success == false) {
                emit TransferFailed(msg.sender, 0x0000000000000000000000000000000000000aBc, recipients[i], values[i]);
            }
            if (success) {
                totalSuccess++;
                totalSent = totalSent + values[i];
            }
        }

        require(totalSuccess > 0, 'All transfers failed');
        payFeeAndGiveChange(totalSuccess, msg.value, totalSent);
        emit TransferMultiSent(msg.sender, 0x0000000000000000000000000000000000000aBc, 'NATIVE', totalSent);
    }

    function payFeeAndGiveChange(uint256 _totalSuccess, uint256 _valueSent, uint256 _totalSent) internal {
        uint256 feeToPay = minimumRatePerTx >= _totalSuccess * ratePerAddress
            ? minimumRatePerTx
            : _totalSuccess * ratePerAddress;
        if (feeToPay > 0) {
            payable(feeAddress).transfer(feeToPay);
        }

        if (_valueSent > feeToPay) {
            payable(msg.sender).transfer(_valueSent - _totalSent - feeToPay);
        }
    }

    function setRates(uint256 _ratePerAddress, uint256 _minimumRatePerTx) external onlyOwner {
        ratePerAddress = _ratePerAddress;
        minimumRatePerTx = _minimumRatePerTx;
    }

    function setFeeAddress(address _feeAddress) external onlyOwner {
        require(_feeAddress != address(0), 'Cannot be zero address');
        feeAddress = _feeAddress;
    }

    function setMaxTransfersPerTx(uint256 _maxTransfersPerTx) external onlyOwner {
        require(_maxTransfersPerTx > 0, 'Max transfers limit is zero');
        maxTransfersPerTx = _maxTransfersPerTx;
    }

    modifier whenFeeSent(uint256 addressesCount, uint256 amountsCount) {
        require(addressesCount <= maxTransfersPerTx, 'Number of transfers exceed the limit');
        require(addressesCount > 0, 'No addresses specified');
        require(addressesCount == amountsCount, 'Addresses count should match amounts counts');
        uint256 maxFee = minimumRatePerTx >= addressesCount * ratePerAddress
            ? minimumRatePerTx
            : addressesCount * ratePerAddress;
        require(msg.value >= maxFee, 'Insufficient fee sent');
        _;
    }

    receive() external payable {
        revert('Cannot accept native coin directly.');
    }

    /**
     * @notice Allows the owner to recover ERC20 tokens sent to the contract by mistake
     * @param _token: token address
     */
    function recoverERC20Token(address _token, address _recepient) external onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance != 0, 'Cannot recover zero balance');

        IERC20(_token).transfer(address(_recepient), balance);

        emit TokenRecoveryERC20(_token, _recepient, balance);
    }

    /**
     * @notice Allows the owner to recover ERC721 tokens sent to the contract by mistake
     * @param tokenAddress: token address
     * @param tokenId: token Id
     */

    function recoverERC721Token(address tokenAddress, address recepient, uint256 tokenId) external onlyOwner {
        IERC721(tokenAddress).safeTransferFrom(address(this), address(recepient), tokenId, '');
        emit TokenRecoveryERC721(tokenAddress, recepient, tokenId);
    }

    /**
     * @notice Allows the owner to recover native coins sent to the contract by mistake
     * @dev Callable by owner
     */
    function recoverNativeCoin(address recepient) public payable onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = payable(address(recepient)).call{value: balance}('');
        require(success);
        emit NativeCoinRecovery(recepient, balance);
    }

    /**
     * @notice Allows the owner to toggle contract's pause status
     * @dev Callable by owner
     */
    function togglePause() external onlyOwner {
        if (paused()) {
            _unpause();
        } else _pause();
    }
}
