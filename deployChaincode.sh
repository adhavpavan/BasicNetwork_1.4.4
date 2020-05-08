export CHANNEL_NAME=mychannel
export CC_NAME=fabcar
export CC_PATH=github.com/fabcar/go
export CC_VERSION=2.0

echo "========== Install Chaincode Using CLI on Peer0 Org1 =========="
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "export CORE_PEER_ADDRESS=peer0.org1.example.com:7051" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" \
    cli peer chaincode install -n $CC_NAME -v $CC_VERSION -p $CC_PATH

echo "========== Install Chaincode Using CLI on Peer0 Org2 =========="
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_ADDRESS=peer0.org2.example.com:9051" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
    -e "CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/channel/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" \
    cli peer chaincode install -n $CC_NAME -v $CC_VERSION -p $CC_PATH

echo "========== Instantiate Chaincode on peer0 =========="
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" \
    cli peer chaincode instantiate -o orderer.example.com:7050 \
    -C mychannel -n $CC_NAME -v $CC_VERSION -c '{"Args":[""]}' -P "OR ('Org1MSP.member', 'Org2MSP.member')" \
    --tls --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

echo "========== Instantiate Chaincode on peer0 Org2 =========="
docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
    cli peer chaincode instantiate -o orderer.example.com:7050 \
    -C mychannel -n $CC_NAME -v $CC_VERSION -c '{"Args":[""]}' -P "OR ('Org1MSP.member', 'Org2MSP.member')" \
    --tls --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

# sleep 5
