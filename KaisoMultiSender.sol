//SPDX-License-Identifier: MIT

import '@openzeppelin/contracts@5.0.2/access/Ownable.sol';
import '@openzeppelin/contracts@5.0.2/utils/Pausable.sol';
import '@openzeppelin/contracts@5.0.2/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts@5.0.2/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts@5.0.2/utils/ReentrancyGuard.sol';

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
