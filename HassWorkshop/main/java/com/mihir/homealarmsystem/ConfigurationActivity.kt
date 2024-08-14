package com.mihir.homealarmsystem

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity

class ConfigurationActivity : AppCompatActivity() {

    private lateinit var ipEditText: EditText
    private lateinit var portEditText: EditText
    private lateinit var tokenEditText: EditText
    private lateinit var saveButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_configuration)

        ipEditText = findViewById(R.id.ipEditText)
        portEditText = findViewById(R.id.portEditText)
        tokenEditText = findViewById(R.id.tokenEditText)
        saveButton = findViewById(R.id.saveButton)

        val sharedPreferences = getSharedPreferences("AppPreferences", Context.MODE_PRIVATE)
        ipEditText.setText(sharedPreferences.getString("ip", ""))
        portEditText.setText(sharedPreferences.getString("port", ""))
        tokenEditText.setText(sharedPreferences.getString("token", ""))

        saveButton.setOnClickListener {
            val ip = ipEditText.text.toString()
            val port = portEditText.text.toString()
            val token = tokenEditText.text.toString()

            with(sharedPreferences.edit()) {
                putString("ip", ip)
                putString("port", port)
                putString("token", token)
                apply()
            }

            finish()
        }
    }

    companion object {
        fun newIntent(context: Context): Intent {
            return Intent(context, ConfigurationActivity::class.java)
        }
    }
}
