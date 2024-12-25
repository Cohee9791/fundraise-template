// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployScript} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint256 favNumber = 0;
    bool greatCourse = false;
    address alice = makeAddr("alice");
    address owner;
    uint256 public constant STARTING_BALANCE = 100 ether;
    FundMe fundMe;

    function setUp() external {
        vm.deal(alice, STARTING_BALANCE);

        console.log("////////////setUp\\\\\\\\\\\\\\\\");
        DeployScript dpl = new DeployScript();
        fundMe = dpl.run();
        owner = fundMe.i_owner();
        console.log("owner address:", owner);
        console.log("alice address:", alice);
    }

    function testDemo() public {
        assertEq(favNumber, 1337);
        assertTrue(greatCourse);

        console.log("testDemo");
    }

    function test_getVersion() public {
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }
    }

    function test_fund_Revert() public {
        ///revert due to limited fund
        vm.expectRevert();
        fundMe.fund();
    }

    function test_getAddressToAmountFunded() public {
        vm.prank(alice);

        fundMe.fund{value: 10 ether}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
        assertEq(amountFunded, 10 ether);
    }

    //test_getfunder
    function test_getfunder() public {
        hoax(alice, STARTING_BALANCE);
        fundMe.fund{value: 10 ether}();
        assertEq(fundMe.getFunder(0), alice);
    }

    function test_withdraw_nonOwner() public {
        vm.startPrank(alice);
        vm.deal(alice, STARTING_BALANCE);
        fundMe.fund{value: 10 ether}();
        vm.expectRevert();
        fundMe.withdraw();
        vm.stopPrank();
    }

    modifier funded() {
        vm.prank(alice);
        fundMe.fund{value: 25 ether}();
        require(address(fundMe).balance > 0);
        _;
    }
    function test_withdraw_owner() public funded {
        ///Arrange ----define the variable we need
        uint256 startingFundMeBalance = address(fundMe).balance;
        ///Act
        vm.prank(owner);
        fundMe.withdraw();

        ///Assert
        assertEq(owner.balance, startingFundMeBalance);
    }
}
