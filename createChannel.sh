export CHANNEL_NAME=mychannel

rm -rf $(ls | grep -E "^fabric-client-kv*")

echo "========== Creating Channel=========="
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" \
    cli peer channel create -o orderer.example.com:7050 \
    -c mychannel -f /etc/hyperledger/channel/mychannel.tx --tls \
    --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" \
    -e "CORE_PEER_ADDRESS=peer0.org1.example.com:7051" \
    cli peer channel join -b mychannel.block

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" \
    peer1.org1.example.com peer channel fetch newest mychannel.block \
    -c mychannel --orderer orderer.example.com:7050 --tls \
    --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" \
    peer1.org1.example.com peer channel join -b mychannel.block

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
    peer0.org2.example.com peer channel fetch newest mychannel.block -c mychannel \
    --orderer orderer.example.com:7050 --tls \
    --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
    peer0.org2.example.com peer channel join -b mychannel.block

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
    peer1.org2.example.com peer channel fetch newest mychannel.block -c mychannel \
    --orderer orderer.example.com:7050 --tls \
    --cafile /etc/hyperledger/channel/crypto-config/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" \
    -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/channel/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" \
    peer1.org2.example.com peer channel join -b mychannel.block

# echo "========== Channel Creation completed =========="
