
# DS18B20-Correct-Reading-ESP8266
Correct reading of DS18B20 by ESP8266 NodeMCU

In most projects reading of DS18b20 sensors is incorrect. 
This is because it has relatively long conversion time - from 93mS to 750mS.
That's why reading scratch pad of the sensor immediately after Convert T command [44h] actually gives not current but last time measured temperature before this command. This has two negatives:
1. First reading is always 85*C as the power on reset register value is +85°C.
2. One cycle delay

If readings are done often there could be low impact but my reading is once per minute and I wanted to have "Real" data.
Fortunately DS18b20 pulls down data line during conversion and we can "sense" the perfect time when exactly all sensors finish this process and can read data after it.
