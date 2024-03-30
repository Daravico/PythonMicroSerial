clear, clc
pause(2)

% -----------------------------------------------------------------
% ARDUINO SETUP.
% -----------------------------------------------------------------
%
% Installing the Arduino Package.
% pkg install -forge arduino

% Loading the Package.
pkg load arduino

% Opening the Arduino Setup Script.
% arduinosetup

% Creating the Arduino object.
a = arduino('COM3');

% Visualizing the Arduino variables.
a

% Turning on and off the LED as a demostration.
led_pin = "d13";

%{
for i = 1:10
  writeDigitalPin(a, led_pin, 1);
  pause(0.5);
  writeDigitalPin(a, led_pin, 0);
  pause(0.5);
end
%}

% Looking up for the available PWM terminals.
getPWMTerminals(a)

% Looking up for the available Servo terminals.
getServoTerminals(a)

% -----------------------------------------------------------------
% SERVOS SETUP (MG995)
% -----------------------------------------------------------------
servo1 = servo(a, "d9", "minpulseduration", 0.5e-3, "maxpulseduration", 2.4e-3);
writePosition(servo1, 0.5);

servo2 = servo(a, "d10", "minpulseduration", 1e-3, "maxpulseduration", 1.75e-3);
% servo2 = servo(a, "d10", "minpulseduration", 0.6e-3, "maxpulseduration", 2.4e-3);
writePosition(servo2, 0.5);

servo3 = servo(a, "d11", "minpulseduration", 1e-3, "maxpulseduration", 1.75e-3);
% servo3 = servo(a, "d11", "minpulseduration", 0.6e-3, "maxpulseduration", 2.4e-3);

writePosition(servo3, 0.5);
%}
% -----------------------------------------------------------------
% DH SETUP
% -----------------------------------------------------------------

% Constantes.
l = [1, 5, 3];
A = [pi/2, 0 ,0];

% Variables (Default values).
q = [0, 0, 0];

% Rango de valores para los ángulos.
ranges = [[-90, 90]; [0, 90]; [0, 90]];

% Matrices DH.
DH10 = DH(q(1),   l(1),   0,      A(1));
DH21 = DH(q(2),   0,      l(2),   A(2));
DH32 = DH(q(3),   0,      l(3),   A(3));

% Matriz resultante.
matrixDH = DH10 * DH21 * DH32;

% Estableciendo punto final (Siempre el origen del punto).
puntoFinal = [0;0;0;1];

% Calculando posición de efector final con respecto al origen.
efectorFinal = round(matrixDH * puntoFinal .* 100) / 100

% -----------------------------------------------------------------
% MAPPEO.
% -----------------------------------------------------------------
clc

while 1

  disp("OPTIONS:")
  disp("1 - Actuator Q1")
  disp("2 - Actuator Q2")
  disp("3 - Actuator Q3")
  disp("9 - Salir")

  select = input("Select: ");

  clc

  if select == 9
    disp("Adio")
    break
  end

  degrees = input("Value (°Degrees): ");

  q(select) = deg2rad(degrees);
  servoValue = Degree2Percentage(degrees, -90, 90, 0, 1);

  DH10 = DH(q(1),   l(1),   0,      A(1));
  DH21 = DH(q(2),   0,      l(2),   A(2));
  DH32 = DH(q(3),   0,      l(3),   A(3));

  writePosition(servo1, servoValue);

  rad2deg(q)

  matrixDH = DH10 * DH21 * DH32

  efectorFinal = round(matrixDH * puntoFinal .* 100) / 100

end



