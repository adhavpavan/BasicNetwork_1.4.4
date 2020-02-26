const express = require('express')
const prometheus = require('prom-client')
const axios = require('axios').default
const app = express()
const port = 9091

const hostname = "localhost"
const couchdb_dbname = "mychannel_test_cc"
axios.timeout = 1000;

const orderer_health_endpoint = `http://${hostname}:8443/healthz`
const peer_health_endpoint = `http://${hostname}:9440/healthz`
const ca_health_endpoint = `http://${hostname}:7054/cainfo`
const couchdb_health_endpoint = `http://${hostname}:5984/${couchdb_dbname}`

const orderer_gauge = new prometheus.Gauge({ name: 'orderer_health', help: 'livliness probe for orderer' });
const peer_gauge = new prometheus.Gauge({ name: 'peer_health', help: 'livliness probe for peer' });
const ca_gauge = new prometheus.Gauge({ name: 'ca_health', help: 'livliness probe for ca' });
const couchdb_gauge = new prometheus.Gauge({ name: 'couchdb_health', help: 'livliness probe for couchdb' });


const check_orderer_health = async () => {
    try {
        let response = await axios.get(orderer_health_endpoint)
        response.data.status == "OK" ? orderer_gauge.set(1) : orderer_gauge.set(0)
    } catch (err) {
        orderer_gauge.set(0)
        console.log(err.message)
    }
}

const check_peer_health = async () => {
    try {
        let response = await axios.get(peer_health_endpoint)
        response.data.status == "OK" ? peer_gauge.set(1) : peer_gauge.set(0)
    } catch (err) {
        peer_gauge.set(0)
        console.log(err.message)
    }
}

const check_ca_health = async () => {
    try {
        let response = await axios.get(ca_health_endpoint)
        response.data.success == true ? ca_gauge.set(1) : ca_gauge.set(0)
    } catch (err) {
        ca_gauge.set(0)
        console.log(err.message)
    }
}

const check_couchdb_health = async () => {
    try {
        let response = await axios.get(couchdb_health_endpoint)
        response.data.doc_count > 0 ? couchdb_gauge.set(1) : couchdb_gauge.set(0)
    } catch (err) {
        couchdb_gauge.set(0)
        console.log(err.message)
    }
}

//api for Prometheus
app.get('/metrics', (req, res) => {
    promises = [check_orderer_health(), check_peer_health(), check_ca_health(), check_couchdb_health()]
    Promise.all(promises).then(() => {
        res.set('Content-Type', prometheus.register.contentType);
        res.end(prometheus.register.metrics());
    })
});


app.listen(port, () => console.log(`Listening on port ${port}!`))

module.exports = {
    check_orderer_health
}
