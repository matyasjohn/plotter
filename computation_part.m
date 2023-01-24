clc, clear all, close all


% preparing canvas
hang_points_distance = 100;
height_of_hang_points = 100;

boundary_zone_y_axis = 20;
boundary_zone_x_axis = 15;

canvas_xy_size = [hang_points_distance - 2*boundary_zone_x_axis, height_of_hang_points - 2*boundary_zone_y_axis];

robot_position_x = hang_points_distance/2;
robot_position_y = height_of_hang_points - boundary_zone_y_axis;

robot_strings_x = [0 robot_position_x hang_points_distance];
robot_strings_y = [height_of_hang_points robot_position_y height_of_hang_points];




% preparing gcode
g_code = fileread("test_7.nc");
gcode_lines = splitlines(string(g_code));


draw_on_off = 0;

coords_x = [0 0];
coords_y = [0 0];

% preparing previous layer for later
previous_line = split(gcode_lines(3), " ");
previous_line(1) = [];

for n=1:length(previous_line)
    current_command = char(previous_line(n));
        
    if current_command(1) == 'G'
            draw_on_off = string(current_command);

    elseif current_command(1) == 'X'
        current_command(1) = [];
        coords_x(1) = double(string(current_command));
        %ogabavanie systemu
        coords_x(2) = double(string(current_command));
    
    elseif current_command(1) == 'Y'
        current_command(1) = [];
        coords_y(1) = double(string(current_command));
        %ogabavanie systemu
        coords_y(2) = double(string(current_command));
    end

end

% Main g-code parsing
hold on
for i=4:length(gcode_lines)-1
    current_line = split(gcode_lines(i), " ");
    current_line(1) = [];

    for n=1:length(current_line)
        current_command = char(current_line(n));
        
        if current_command(1) == 'G'
            last_state_drawing = draw_on_off;
            draw_on_off = string(current_command);

        elseif current_command(1) == 'X'
            current_command(1) = [];
            coords_x(2) = double(string(current_command));
        
        elseif current_command(1) == 'Y'
            current_command(1) = [];
            coords_y(2) = double(string(current_command));

        end

    end
    % Motor calculation <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    motor_speeds_multiplier = [1 1]; % left right
    

    old_strings_length = [sqrt(coords_x(1)^2 + (height_of_hang_points-coords_y(1))^2), sqrt((hang_points_distance-coords_x(1))^2 + (height_of_hang_points-coords_y(1))^2) ];
    new_strings_length = [sqrt(coords_x(2)^2 + (height_of_hang_points-coords_y(2))^2), sqrt((hang_points_distance-coords_x(2))^2 + (height_of_hang_points-coords_y(2))^2) ];
    
    % how much should left and right string change <<<
    difference_between_strings = [ old_strings_length(1)-new_strings_length(1), old_strings_length(2)-new_strings_length(2)];
    
    strings_length_difference = abs(difference_between_strings);

    % calculating speeds for same amount of time spent on movement,
    % decreasing speed of longer move       (could be worth to try accelerating for longer move)
    [longer_string, longer_string_index] = max(strings_length_difference);
    shorter_string = min(strings_length_difference);
    speed_decrease = shorter_string/longer_string;
    
    % final speed multiplier
    motor_speeds_multiplier(longer_string_index) = motor_speeds_multiplier(longer_string_index)*speed_decrease;
    
    disp(motor_speeds_multiplier)
    

    

    %TO DO motor direction + amount implementation
    


    % main drawing part <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
 
    if  draw_on_off == "G00"
        plot(coords_x,coords_y,'g')
    
    % Drawing
    elseif draw_on_off == "G01"
        plot(coords_x,coords_y,'b',LineWidth = 2)
    
    end

    % storing coords for next loop
    coords_x(1) = coords_x(2);
    coords_y(1) = coords_y(2);

end



% Canvas ploting

plot([0 hang_points_distance],[hang_points_distance hang_points_distance],'k-' )

plot(robot_strings_x,robot_strings_y,'k-' )

plot(robot_position_x,robot_position_y,'ro')

% Canvas
rectangle('Position',[hang_points_distance/2-canvas_xy_size(1)/2 boundary_zone_y_axis, canvas_xy_size(1) canvas_xy_size(2)],'EdgeColor','#CCCCCC')

hold off

axis([0 hang_points_distance 0 height_of_hang_points])
axis equal
shg