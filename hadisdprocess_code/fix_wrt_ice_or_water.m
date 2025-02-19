
%% Calculate water vapor pressure, saturated water vapor pressure, wet bulb temperature

function [e_v, e_s, Tw] = fix_wrt_ice_or_water(temperatures, dewpoints, station_pressure)
    % Calculate the vapour pressures and wet-bulb temperatures, adjusting
    % for an ice- or water-bulb as appropriate based on Tw.
    %
    % Parameters:
    % temperatures: Temperature array [deg C]
    % dewpoints: Dewpoint temperature array [deg C]
    % station_pressure: Station pressure array [hPa]
    %
    % Returns:
    % e_v: Vapour pressure [hPa]
    % e_s: Saturation vapour pressure [hPa]
    % Tw: Wet-bulb temperature [deg C]

    % Calculate vapour pressures
    e_v = calculate_e_v_wrt_water(dewpoints, station_pressure);
    e_v_ice = calculate_e_v_wrt_ice(dewpoints, station_pressure);

    % Calculate saturation vapour pressures
    e_s = calculate_e_v_wrt_water(temperatures, station_pressure);
    e_s_ice = calculate_e_v_wrt_ice(temperatures, station_pressure);

    % Calculate wet-bulb temperatures
    Tw = calculate_Tw(e_v, station_pressure, dewpoints, temperatures);
    Tw_ice = calculate_Tw(e_v_ice, station_pressure, dewpoints, temperatures);

    % Adjust for ice-bulbs where Tw <= 0
    ice_indices = Tw <= 0; % Logical index for Tw <= 0
    e_v(ice_indices) = e_v_ice(ice_indices);
    e_s(ice_indices) = e_s_ice(ice_indices);
    Tw(ice_indices) = Tw_ice(ice_indices);
end

