/* sample.cpp for TOPPERS/ATK(OSEK) */ 

// ECRobot++ API
#include "Motor.h"
#include "TouchSensor.h"
//#include "Bluetooth.h"
//#include "BTConnection.h"
#include "Nxt.h"
#include "Clock.h"
#include "Lcd.h"

using namespace ecrobot;

extern "C"
{
#include "kernel.h"
#include "kernel_id.h"
#include "ecrobot_interface.h"

//=============================================================================
// Device objects
Motor motorBase(PORT_A); // brake by defalut
Motor motorBraco(PORT_B); // brake by defalut
Motor motorGarra(PORT_C); // brake by defalut
TouchSensor  toqueEsteira(PORT_1);
TouchSensor  toqueRecipiente(PORT_2);
//Bluetooth bt;

/* nxtOSEK hook to be invoked from an ISR in category 2 */
void user_1ms_isr_type2(void)
{
	SleeperMonitor(); // needed for I2C device and Clock classes
}

TASK(TaskMain)
{
	Nxt nxt;
	Clock clock;
	Lcd lcd;
	U32 countGarra;
	U32 countGarraAnt;
	int strength;
	//BTConnection btConnection(bt, lcd, nxt);

	// Connect as slave
	//btConnection.connect(PASSKEY);

	// Fechar a garra
	motorGarra.setCount(0);
	motorGarra.setPWM(-60);
	countGarraAnt = 1000;
	strength = 0;
	//while(  motorGarra.getCount() > -49)
	while (strength < 7)
	{
		lcd.clear();
		lcd.putf("sdn", "Garra: ", motorGarra.getCount());
		lcd.disp();
		countGarra = motorGarra.getCount();
		if (countGarraAnt == countGarra)
		  strength++;
		clock.wait(100);
		countGarraAnt = countGarra;
	}
	motorGarra.setPWM(0);
	clock.wait(700);

	// Levantar Braço
	motorBraco.setCount(0);
	motorBraco.setPWM(50);
	while(motorBraco.getCount() < 200)
	{
		lcd.clear();
		lcd.putf("sdn", "Braco: ", motorBraco.getCount());
		lcd.disp();
	}
	motorBraco.setPWM(0);
	clock.wait(700);
		
	// Mover a base ao recipiente
	motorBase.setPWM(50);
	while(! toqueRecipiente.isPressed() )
	{
		lcd.clear();
		lcd.putf("sdn", "Base: ", motorBase.getCount());
		lcd.disp();
	}
	motorBase.setPWM(0);
	clock.wait(700);

	// Baixar o Braço ao Recipiente
	//motorBraco.setCount(0);
	motorBraco.setPWM(-20);
	while(motorBraco.getCount() > 0)
	{
		lcd.clear();
		lcd.putf("sdn", "Braco: ", motorBraco.getCount());
		lcd.disp();
	}
	motorBraco.setPWM(0);
	clock.wait(700);

	// Abrir a garra
	motorGarra.setCount(0);
	motorGarra.setPWM(50);
	while(motorGarra.getCount() < 49)
	{
		lcd.clear();
		lcd.putf("sdn", "Garra: ", motorGarra.getCount());
		lcd.disp();
	}
	motorGarra.setPWM(0);
	clock.wait(700);

	// Levantar Braço
	motorBraco.setCount(0);
	motorBraco.setPWM(50);
	while(motorBraco.getCount() < 200)
	{
		lcd.clear();
		lcd.putf("sdn", "Braco: ", motorBraco.getCount());
		lcd.disp();
	}
	motorBraco.setPWM(0);
	clock.wait(700);

	// Mover a base à esteira
	motorBase.setPWM(-50);
	while(! toqueEsteira.isPressed() )
	{
		lcd.clear();
		lcd.putf("sdn", "Base: ", motorBase.getCount());
		lcd.disp();
	}
	motorBase.setPWM(0);
	clock.wait(700);

	// Baixar a braço à esteira
	//motorBraco.setCount(0);
	motorBraco.setPWM(-20);
	while(! toqueRecipiente.isPressed())
	{
		lcd.clear();
		lcd.putf("sdn", "Braco: ", motorBraco.getCount());
		lcd.disp();
	}
	motorBraco.setPWM(0);
	clock.wait(700);
//	}
}
}
