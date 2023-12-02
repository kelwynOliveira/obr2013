/* sample.cpp for TOPPERS/ATK(OSEK) */

// ECRobot++ API
#include "Motor.h"
#include "Nxt.h"
#include "Clock.h"
#include "Lcd.h"
#include "Bluetooth.h"
#include "BTConnection.h"
#include "SonarSensor.h"
#include "LightSensor.h"
using namespace ecrobot;

extern "C"
{
#include "kernel.h"
#include "kernel_id.h"
#include "ecrobot_interface.h"

//=============================================================================
// Device objects
Motor motorA(PORT_A); // brake by defalut
LightSensor luz(PORT_2);
SonarSensor  sonar(PORT_1);
Nxt nxt;
Clock clock;
Lcd lcd;
S16 nSonar;
Bluetooth bt;

// Constants
//static const CHAR* PASSKEY = "1234";
static const U8 BD_ADDRESS[7] = {0x00, 0x16, 0x53, 0x03, 0x32, 0xD4, 0x00};


ecrobot::Motor::Motor(ePortM port, bool brake)
{
	lcd.clear();
	lcd.putf("sn", "Oi pessoal.");
	lcd.disp();
	clock.wait(5000);

};

ecrobot::Motor::~Motor(void)
{
	lcd.clear();
	lcd.putf("sn", "Tchau pessoal.");
	lcd.disp();
};

/* nxtOSEK hook to be invoked from an ISR in category 2 */
void user_1ms_isr_type2(void)
{
	SleeperMonitor(); // needed for I2C device and Clock classes
}

void moverEsteira(void)
{
	while(1)
	{
	    nSonar = sonar.getDistance();
		if ((nxt.getButtons() == Nxt::ENTR_ON) || nSonar < 10)
		{
			lcd.clear();
			lcd.putf("sn", "Parando.");
			lcd.disp();
			clock.wait(900);
			motorA.setPWM(0);   // pwm=0 and count=0
			motorA.setCount(0);
			break;
		}
		else
		{
			motorA.setPWM(60);
		}

		lcd.clear();
		lcd.putf("sdn", "Motor A:", motorA.getCount(),5);
		lcd.putf("sdn", "Sensor1:", nSonar,5);
		lcd.disp();

		clock.wait(100);
	}
}
TASK(TaskMain)
{
//	U8 moveBraco = 1;
//	U8 moveEsteira = 0;
	U8 moveEsteira = 1;

//	BTConnection btConnection(bt, lcd, nxt);

	// Connect as master
//	btConnection.connect(PASSKEY, BD_ADDRESS);

//	while(1)
//	{
//		bt.receive(&moveEsteira, 1);
	    lcd.clear();
	    lcd.putf("sd\n", "Recebido: ", moveEsteira);
	    lcd.disp();
		if (moveEsteira > 0)
		{
		   moverEsteira();
		   moveEsteira = 0;
//		   bt.send(&moveBraco, 1);
		};
		motorA.~Motor();
//	}

}
}
