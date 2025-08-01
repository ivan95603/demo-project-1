require('dotenv').config()

const express = require('express')
const jwt = require('jsonwebtoken')
const pg = require('pg')
const mqtt = require("mqtt");

const app = express()
const port = 3000

app.use(express.json())

const mqtt_protocol = 'mqtt'
const mqtt_host = 'mosquitto'
const mqtt_port = '1883'
const mqtt_clientId = `mqtt_${Math.random().toString(16).slice(3)}`

const mqtt_connectUrl = `${mqtt_protocol}://${mqtt_host}:${mqtt_port}`

let refreshTokens = []


////////////////////////////////////////////////////////////
/////////////////////////// MQTT ///////////////////////////
////////////////////////////////////////////////////////////


const mqtt_client = mqtt.connect(mqtt_connectUrl, {
    mqtt_clientId,
    clean: true,
    connectTimeout: 4000,
    // username: 'username',
    // password: 'password',
    reconnectPeriod: 1000,
})

const mqtt_topic_fan = '/fan_power'
const mqtt_topic_fan_request = mqtt_topic_fan + '/request'
const mqtt_topic_fan_response = mqtt_topic_fan + '/response'

mqtt_client.on('connect', () => {
    console.log('Connected')

    mqtt_client.subscribe([mqtt_topic_fan_request], () => {
        console.log(`Subscribe to topic '${mqtt_topic_fan_request}'`)
        mqtt_client.publish(mqtt_topic_fan_response, '1000', { qos: 1, retain: false }, (error) => {
            if (error) {
                console.error(error)
            }
        })
    })
})

mqtt_client.on('message', (mqtt_topic_fan_request, payload) => {
    console.log('---------Received Message:', mqtt_topic_fan_request, payload.toString())

    console.log('Sending fan data')

    mqtt_client.publish(mqtt_topic_fan_response, '1000', { qos: 1, retain: false }, (error) => {
        if (error) {
            console.error(error)
        }
    })
})


// REST endpoint to trigger MQTT message publish
app.get('/mqtt', async (req, res) => {

    ////////////////////////////////////////////////////////////////////////////////////////
    const client = new pg.Client({
        user: 'postgres',
        password: 'postgres',
        host: 'postgres',
        port: 5432,
        database: 'demodb',
    })
    await client.connect()

    const res_sql = await client.query('SELECT data_value FROM public.slider_values ORDER BY id DESC LIMIT 1;')

    value = '' + res_sql.rows[0].data_value
    console.log(value)

    ////////////////////////////////////////////////////////////////////////////////////////

    console.log("Sending MQTT message")

    const mqtt_client = mqtt.connect(mqtt_connectUrl, {
        mqtt_clientId,
        clean: true,
        connectTimeout: 4000,
        // username: 'username',
        // password: 'password',
        reconnectPeriod: 1000,
    })
    // console.log(mqtt_client)

    mqtt_client.on('connect', () => {
        console.log("connect")
        mqtt_client.publish(mqtt_topic_fan_response, value, { qos: 1, retain: false }, (error) => {
            if (error) {
                console.error(error)
                console.log('ERROR')
            } else {
                console.log('NOT ERROR')
            }
        })
    })

    // mqtt_client.on("message", (topic, message) => {
    //     // message is Buffer
    //     console.log(message.toString());
    //     mqtt_client.end();
    // });
    res.send("Sent MQTT message to " + mqtt_topic_fan_response)
})

/////////////////////// EOF MQTT ///////////////////////////

////////////////////////////////////////////////////////////
/////////////////// REST Authentication ////////////////////
////////////////////////////////////////////////////////////

function generateAccessToken(user) {
    return jwt.sign(user, process.env.ACCESS_TOKEN_SECRET, { expiresIn: '600s' })
}

function authenticateToken(req, res, next) {
    const authHeader = req.headers['authorization']
    const token = authHeader && authHeader.split(' ')[1]
    if (token == null) return res.sendStatus(401)

    jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
        console.log(err)
        if (err) return res.sendStatus(403)
        req.user = user
        next()
    })
}

app.post('/token', (req, res) => {
    const refreshToken = req.body.token
    if (refreshToken == null) return res.sendStatus(401)
    if (!refreshTokens.includes(refreshToken)) return res.sendStatus(403)
    jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET, (err, user) => {
        if (err) return res.sendStatus(403)
        const accessToken = generateAccessToken({ name: user.name })
        res.json({ accessToken: accessToken })
    })
})

app.delete('/logout', (req, res) => {
    refreshTokens = refreshTokens.filter(token => token !== req.body.token)
    res.sendStatus(204)
})

app.post('/login', (req, res) => {
    // Authenticate User

    const username = req.body.username
    const user = { name: username }

    const accessToken = generateAccessToken(user)
    const refreshToken = jwt.sign(user, process.env.REFRESH_TOKEN_SECRET)
    refreshTokens.push(refreshToken)
    res.json({ accessToken: accessToken, refreshToken: refreshToken })
})

app.get('/users', async (req, res) => {
    const client = new pg.Client({
        user: 'postgres',
        password: 'postgres',
        host: 'postgres',
        port: 5432,
        database: 'demodb',
    })
    await client.connect()

    // const res_sql = await client.query('SELECT $1::text as message', ['Hello world!'])
    // const res_sql = await client.query('SELECT * FROM public.users ORDER BY uid ASC')
    // const res_sql = await client.query("SELECT public.check_login('usr', 'usr')")
    const res_sql = await client.query('SELECT public.check_login($1, $2)', ["usr", "usr"])

    text = res_sql.rows[0]
    console.log(text) // Hello world!
    await client.end()
    res.send(text)
})

// const posts = [
//     {
//         username: 'Kyle',
//         title: 'Post 1'
//     },
//     {
//         username: 'Jim',
//         title: 'Post 2'
//     }
// ]

// app.get('/posts', authenticateToken, (req, res) => {
//     res.json(posts.filter(post => post.username === req.user.name))
// })

/////////////// EOF REST Authentication //////////////////

////////////////////////////////////////////////////////////
////////////////// Embedded Linux Device ///////////////////
////////////////////////////////////////////////////////////

// Method for receiving slider position data from the embedded Linux device
app.post('/slider_data', async (req, res) => {

    const value = req.body.slider_value

    console.log(`SLIDER VALUE RECEIVED: '${value}'`)

    if ((value >= 0) && (value < 4096)) {

        const client = new pg.Client({
            user: 'postgres',
            password: 'postgres',
            host: 'postgres',
            port: 5432,
            database: 'demodb',
        })
        await client.connect()

        date = '2024-07-31 00:00:00+00'
        const res_sql = await client.query('SELECT public.insert_into_slider_data($1, $2)', [date, value])

        const res_sql2 = await client.query('SELECT data_value FROM public.slider_values ORDER BY id DESC LIMIT 1;')

        returned_value = '' + res_sql2.rows[0].data_value
        console.log(returned_value)


        mqtt_client.publish(mqtt_topic_fan_response, value, { qos: 1, retain: false }, (error) => {
            if (error) {
                console.error(error)
            }
        })

        res.json({ sucess: true, value: returned_value })
    }
    else {
        res.json({ sucess: false })
    }
})

/////////////// EOF Embedded Linux Device //////////////////

////////////////////////////////////////////////////////////
/////////////////////// Android App ////////////////////////
////////////////////////////////////////////////////////////

// Endpoint for receiving temperature data from the Android app
app.post('/embedded/report_temperature/:value', (req, res) => {
    console.log("req.params: ")
    console.log(req.params.value)
    res.send('Got a POST request')
})

///////////////////// EOF Android App //////////////////////

app.get('/', (req, res) => {
    res.send('Demo Application')
})

app.listen(port, () => {
    console.log(`Example app listening on port ${port}`)
})