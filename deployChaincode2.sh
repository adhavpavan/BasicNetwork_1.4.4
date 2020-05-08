export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=mychannel
export CC_NAME=fabcar
export CC_PATH=github.com/fabcar/go
export CC_VERSION=1.0

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp

}

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    # export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:8051

}

setGlobalsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

setGlobalsForPeer1Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:10051

}

presetup() {
    echo Vendoring Go dependencies ...
    pushd ./artifacts/src/github.com/fabcar/go
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}
# presetup

CHANNEL_NAME="mychannel"
CC_RUNTIME_LANGUAGE="golang"
VERSION="1"
CC_SRC_PATH="./artifacts/src/github.com/fabcar/go"
CC_NAME="fabcar"

installChaincode() {
    setGlobalsForPeer0Org2
    env
    peer chaincode install -n $CC_NAME -v $CC_VERSION -p $CC_PATH
    # peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    # setGlobalsForPeer0Org2
    # peer lifecycle chaincode install ${CC_NAME}.tar.gz
    # echo "===================== Chaincode is installed on peer0.org2 ===================== "

}

instantiateChainocde() {
    setGlobalsForPeer0Org1
    peer chaincode install -n $CC_NAME -v $CC_VERSION -p $CC_PATH

}

installChaincode

# echo "========== Install Chaincode Using CLI on Peer0 Org1 =========="
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "export CORE_PEER_ADDRESS=peer0.org1.example.com:7051" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n $CC_NAME -v $CC_VERSION -p $CC_PATH

# echo "========== Install Chaincode Using CLI on Peer1 Org1 =========="
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_ADDRESS=peer1.org1.example.com:8051" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n $CC_NAME -v $CC_VERSION -p $CC_PATH

# echo "========== Install Chaincode Using CLI on Peer2 Org1 =========="
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_ADDRESS=peer2.org1.example.com:9051" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n $CC_NAME -v $CC_VERSION -p $CC_PATH

# echo "========== Instantiate Chaincode on peer0 =========="
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n $CC_NAME -v $CC_VERSION -c '{"Args":[""]}' -P "OR ('Org1MSP.member')" --tls --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
