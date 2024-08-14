package com.mihir.homealarmsystem

import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import okhttp3.*
import okio.ByteString
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit

class MainActivity : AppCompatActivity() {

    private lateinit var client: OkHttpClient
    private var webSocket: WebSocket? = null
    private lateinit var statusTextView: TextView
    private lateinit var alarmStateTextView: TextView
    private lateinit var alarmActionButton: Button
    private lateinit var configButton: Button
    private var webSocketUrl = ""
    private var accessToken = ""
    private val reconnectInterval = 3000L // 5 seconds
    private var messageId = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)


        statusTextView = findViewById(R.id.statusTextView)
        alarmStateTextView = findViewById(R.id.alarmStateTextView)
        alarmActionButton = findViewById(R.id.alarmActionButton)
        configButton = findViewById(R.id.configButton)

        loadSettings()

        client = OkHttpClient.Builder()
            .readTimeout(3, TimeUnit.SECONDS)
            .build()

        configButton.setOnClickListener {
            val intent = ConfigurationActivity.newIntent(this)
            startActivity(intent)
        }

        // Automatically connect on startup
        connectWebSocket()

        // Set the action for the alarmActionButton
        alarmActionButton.setOnClickListener {
            val currentState = alarmStateTextView.text.toString().removePrefix("Alarm State: ").trim()
            if (currentState == "disarmed") {
                sendArmAlarmMessage()
            } else {
                showKeypad()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        loadSettings()
        connectWebSocket()
    }


    private fun loadSettings() {
        val sharedPreferences = getSharedPreferences("AppPreferences", Context.MODE_PRIVATE)
        val ip = sharedPreferences.getString("ip", "")
        val port = sharedPreferences.getString("port", "")
        accessToken = sharedPreferences.getString("token", "") ?: ""

        if (ip.isNullOrEmpty() || port.isNullOrEmpty()) {
            webSocketUrl = ""
            statusTextView.text = "Invalid IP or Port"
        } else {
            webSocketUrl = "ws://$ip:$port/api/websocket"
        }
    }


    private fun connectWebSocket() {
        if (webSocketUrl.isEmpty() || accessToken.isEmpty()) {
            statusTextView.text = "Invalid configuration"
            return
        }

        val request = Request.Builder().url(webSocketUrl).build()
        val webSocketListener = MyWebSocketListener()
        webSocket = client.newWebSocket(request, webSocketListener)
    }


    private inner class MyWebSocketListener : WebSocketListener() {
        override fun onOpen(webSocket: WebSocket, response: Response) {
            runOnUiThread {
                statusTextView.text = "Connected"
            }
        }

        override fun onMessage(webSocket: WebSocket, text: String) {
            // Print the received text message to the console
            println("Received text message: $text")
            val message = JSONObject(text)
            var subscribeMessageID = -1
            when (message.getString("type")) {
                "auth_required" -> {
                    val authMessage = "{\"type\": \"auth\", \"access_token\": \"$accessToken\"}"
                    println("sent message: $authMessage")
                    webSocket.send(authMessage)
                }
                "auth_ok" -> {
                    runOnUiThread {
                        statusTextView.text = "Authenticated"
                    }
                    // Send get_states message
                    val getStatesMessage = "{\"id\": ${messageId++}, \"type\": \"get_states\"}"
                    println("sent message: $getStatesMessage")
                    webSocket.send(getStatesMessage)
                    // Subscribe to state_changed events
                    subscribeMessageID = messageId++
                    val subscribeMessage = "{\"id\": ${subscribeMessageID}, \"type\": \"subscribe_events\", \"event_type\": \"state_changed\"}"
                    println("sent message: $subscribeMessage")
                    println("subscribe message ID: $subscribeMessageID")
                    webSocket.send(subscribeMessage)
                }
                "result" -> {
                    if (message.getBoolean("success")) {
                        val result = message.get("result")
                        if (result is JSONArray) {
                            handleGetStatesResult(result)
                        }
                    }
                }
                "event" -> {
                    val eventType = message.getJSONObject("event").getString("event_type")
                    if (eventType == "state_changed") {
                        val eventData = message.getJSONObject("event").getJSONObject("data")
                        handleStateChangedEvent(eventData)
                    }
                }
            }
        }

        override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
            // Print the received binary message to the console
            println("Received binary message: ${bytes.hex()}")
        }

        override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
            webSocket.close(1000, null)
            runOnUiThread {
                statusTextView.text = "Disconnected"
                retryConnection()
            }
        }

        override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
            t.printStackTrace()
            runOnUiThread {
                statusTextView.text = "Unable to connect"
                retryConnection()
            }
        }
    }



    private fun showKeypad() {
        val keypadView = layoutInflater.inflate(R.layout.keypad_layout, null)
        val codeTextView = keypadView.findViewById<TextView>(R.id.codeTextView)

        val dialog = AlertDialog.Builder(this)
            .setView(keypadView)
            .setCancelable(false)
            .create()

        var code = ""

        // Set up button listeners
        val digitButtons = listOf(
            keypadView.findViewById<Button>(R.id.btn0),
            keypadView.findViewById<Button>(R.id.btn1),
            keypadView.findViewById<Button>(R.id.btn2),
            keypadView.findViewById<Button>(R.id.btn3),
            keypadView.findViewById<Button>(R.id.btn4),
            keypadView.findViewById<Button>(R.id.btn5),
            keypadView.findViewById<Button>(R.id.btn6),
            keypadView.findViewById<Button>(R.id.btn7),
            keypadView.findViewById<Button>(R.id.btn8),
            keypadView.findViewById<Button>(R.id.btn9)
        )

        for (button in digitButtons) {
            button.setOnClickListener {
                if (code.length < 4) {
                    code += button.text
                    codeTextView.text = code
                }
                if (code.length == 4) {
                    // Send disarm request with the entered code
                    sendDisarmRequest(code)
                    dialog.dismiss()
                }
            }
        }

        keypadView.findViewById<Button>(R.id.btnBackspace).setOnClickListener {
            if (code.isNotEmpty()) {
                code = code.dropLast(1)
                codeTextView.text = code
            }
        }

        dialog.show()
    }




    private fun sendDisarmRequest(code: String) {
        val disarmMessage = """
        {
          "id": ${messageId++},
          "type": "call_service",
          "domain": "alarmo",
          "service": "disarm",
          "service_data": {
            "entity_id": "alarm_control_panel.alarmo",
            "code": "$code"
          }
        }
    """.trimIndent()

        webSocket?.send(disarmMessage)
    }

    private fun handleGetStatesResult(resultArray: JSONArray) {
        for (i in 0 until resultArray.length()) {
            val entity = resultArray.getJSONObject(i)
            if (entity.getString("entity_id") == "alarm_control_panel.alarmo") {
                val state = entity.getString("state")
                runOnUiThread {
                    alarmStateTextView.text = "Alarm State: $state"
                    updateAlarmActionButton(state)
                }
                break
            }
        }
    }

    private fun handleStateChangedEvent(eventData: JSONObject) {
        val entityId = eventData.getString("entity_id")
        if (entityId == "alarm_control_panel.alarmo") {
            val newState = eventData.getJSONObject("new_state").getString("state")
            runOnUiThread {
                alarmStateTextView.text = "Alarm State: $newState"
                updateAlarmActionButton(newState)
            }
        }
    }

    private fun updateAlarmActionButton(state: String) {
        if (state == "disarmed") {
            alarmActionButton.text = "Arm Alarm"
        } else {
            alarmActionButton.text = "Disarm Alarm"
        }
    }

    private fun sendArmAlarmMessage() {
        val armMessage = """
            {
              "id": ${messageId++},
              "type": "call_service",
              "domain": "alarmo",
              "service": "arm",
              "service_data": {
                "entity_id": "alarm_control_panel.alarmo"
              }
            }
        """.trimIndent()
        println("sent message: $armMessage")
        webSocket?.send(armMessage)
    }

    private fun sendDisarmAlarmMessage() {
        val disarmMessage = """
            {
              "id": ${messageId++},
              "type": "call_service",
              "domain": "alarmo",
              "service": "disarm",
              "service_data": {
                "entity_id": "alarm_control_panel.alarmo",
                "code": "1234"
              }
            }
        """.trimIndent()
        println("sent message: $disarmMessage")
        webSocket?.send(disarmMessage)
    }

    private fun retryConnection() {
        val handler = Handler(Looper.getMainLooper())
        handler.postDelayed({
            connectWebSocket()
        }, reconnectInterval)
    }

    override fun onDestroy() {
        super.onDestroy()
        client.dispatcher.executorService.shutdown()
    }
}