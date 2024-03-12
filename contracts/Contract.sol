// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract UserInfoUpdate {
    address public owner;

    mapping(address => User) private users;

    struct User {
        address addr;
        string name;
        string stu_id;
        string email;
        string phone_number;
    }

    event InfoUpdated (
        address indexed addr,
        string name,
        string stu_id,
        string email,
        string phone_number
    );

    constructor() {
        // Whoever deploys the contract will be the owner
        owner = msg.sender;
    }

    function updateUserInfo(string memory _name, string memory _stu_id, string memory _email, string memory _phone_number) public returns (bool){
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_stu_id).length == 8, "StudentID must have campus code & 5 digits");
        require(bytes(_email).length > 0, "Email cannot be empty");
        require(bytes(_phone_number).length == 10, "Phone number must have 10 digits");

        // Check if email and phone number contain any spaces
        require(!containsSpace(_stu_id), "StudentID cannot contain spaces");
        require(!containsSpace(_email), "Email cannot contain spaces");
        require(!containsSpace(_phone_number), "Phone number cannot contain spaces");

        // Check if email contains @gmail.com or @outlook.com
        require(
            keccak256(abi.encodePacked((substring(_email, "@gmail.com")))) == keccak256(abi.encodePacked(("@gmail.com"))) ||
            keccak256(abi.encodePacked((substring(_email, "@outlook.com")))) == keccak256(abi.encodePacked(("@outlook.com"))),
            "Email must contain @gmail.com or @outlook.com"
        );

        require(
            keccak256(abi.encodePacked((substring(_stu_id, "SWS")))) == keccak256(abi.encodePacked(("SWS"))) ||
            keccak256(abi.encodePacked((substring(_stu_id, "SWD")))) == keccak256(abi.encodePacked(("SWD"))) ||
            keccak256(abi.encodePacked((substring(_stu_id, "SWH")))) == keccak256(abi.encodePacked(("SWH"))),
            "StudentID must starts with SWS or SWH or SWD"
        );

        // Check if name has at least two words with capital starting letter
        require(checkName(_name), "Name must have at least two words, with capital of each starting letter");

        User memory user = User({
            addr: msg.sender,
            name: _name,
            stu_id: _stu_id,
            email: _email,
            phone_number: _phone_number
        });

        users[msg.sender] = user;

        emit InfoUpdated(msg.sender, user.name, user.stu_id, user.email, user.phone_number);

        return true;
    }

    function containsSpace(string memory str) private pure returns (bool) {
        bytes memory strBytes = bytes(str);
        for(uint i = 0; i < strBytes.length; i++) {
            if(strBytes[i] == ' ') {
                return true;
            }
        }
        return false;
    }

    function substring(string memory str, string memory substr) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory substrBytes = bytes(substr);

        uint start = 0;
        bool found = false;
        for(uint i = 0; i < strBytes.length; i++) {
            if(strBytes[i] == substrBytes[0]) {
                start = i;
                found = true;
                for(uint j = 0; j < substrBytes.length; j++) {
                    if(strBytes[i + j] != substrBytes[j]) {
                        found = false;
                        break;
                    }
                }

                if(found) {
                    break;
                }
            }
        }

        require(found, "Only accept email with @gmail.com or @outlook.com");

        bytes memory result = new bytes(substrBytes.length);
        for(uint i = 0; i < substrBytes.length; i++) {
            result[i] = strBytes[start + i];
        }

        return string(result);
    }

    function checkName(string memory name) private pure returns (bool) {
        bytes memory nameBytes = bytes(name);
        if(nameBytes.length == 0) {
            return false;
        }

        // Check if name has at least two words
        uint wordCount = 0;
        for(uint i = 0; i < nameBytes.length; i++) {
            if(nameBytes[i] == ' ') {
                wordCount++;
            }
        }

        if(wordCount < 1) {
            return false;
        }

        // Check if each word starts with a capital letter
        for(uint i = 0; i < nameBytes.length; i++) {
            // ASCII value of space is 32
            if(i == 0 || uint8(nameBytes[i - 1]) == 32) {
                // ASCII values of capital letters are from 65 to 90
                if(uint8(nameBytes[i]) < 65 || uint8(nameBytes[i]) > 90) {
                    return false;
                }
            }
        }

        return true;
    }
}
