#define seguidor S3
 
task main()
{
  int leitura;
  int motorB;
  int motorC;
  int reparo;
  int velocidade=60;
  int erro;
  int media;

  SetSensorColorRed(seguidor);
  int preto = 40;
  int branco = 10;

  while (preto > branco)
  {
    leitura = Sensor (seguidor);
    media = (preto+branco)/2;
    erro = (leitura-media);
    reparo = (3*erro);
    motorB = 6*velocidade + reparo;
    motorC = velocidade - 2*reparo;
    OnFwd (OUT_B,motorB);
    OnFwd (OUT_C,motorC);
    Wait (500);
  }

  while (branco>preto)
  {
    RotateMotor (OUT_C,80,360);
    Wait (500);
  }
}
