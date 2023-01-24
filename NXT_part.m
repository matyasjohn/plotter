%Setup

clc, clear all, close all
COM_CloseNXT all

handle = COM_OpenNXT();
COM_SetDefaultNXT(handle);
Ports = [MOTOR_A  MOTOR_B];

mL                   = NXTMotor(Ports(1));
mL.SpeedRegulation   = false;
mL.ActionAtTachoLimit = 'Brake';

mR                   = NXTMotor(Ports(2));
mR.SpeedRegulation   = false;
mR.ActionAtTachoLimit = 'Brake';


    %TO DO motor direction + amount implementation

    if difference_between_strings(1)<0
        mL.Power             = round((-100*motor_speeds_multiplier(1)),0);
        mL.TachoLimit        = int64(10*abs(difference_between_strings(1)));
    else
        mL.Power             = round((-100*motor_speeds_multiplier(1)),0);
        mL.TachoLimit        = int64(10*difference_between_strings(1));
    end

    if difference_between_strings(2)<0
        mR.Power             = round((-100*motor_speeds_multiplier(2)),0);
        mR.TachoLimit        = int64(10*abs(difference_between_strings(2)));
    else
        mR.Power             = round((100*motor_speeds_multiplier(2)),0);
        mR.TachoLimit        = int64(10*difference_between_strings(2));
    end
    
    mL.SendToNXT();
    mR.SendToNXT();
    
    mL.WaitFor();
    mR.WaitFor();
    

COM_CloseNXT(handle);