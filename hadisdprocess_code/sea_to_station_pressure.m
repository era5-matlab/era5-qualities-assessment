
%% Convert sea level pressure to station pressure
function Pmst = sea_to_station_pressure(Pmsl, T, Z)
    % Convert sea level pressure to station pressure
    %
    % Parameters:
    % Pmsl: Sea level pressure [hPa]
    % T: Temperature at the station [°C]
    % Z: Station height above sea level [m]
    %
    % Returns:
    % Pmst: Station pressure [hPa]

    % Constants
    L = 0.0065; % Temperature lapse rate [K/m]
    exponent = 5.625;

    % Convert temperature to Kelvin
    T_kelvin = T + 273.15;

    % Compute station pressure
    Pmst = Pmsl .* (T_kelvin ./ (T_kelvin + L * Z)).^exponent;
end

