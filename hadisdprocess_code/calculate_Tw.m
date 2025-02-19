
%% Calculated ball temperature
function Tw = calculate_Tw(e_v, P, Td, t)
    % Calculate the wet-bulb temperature
    %
    % Reference:
    % Jensen, M. E., Burman, R. D., and Allen, R. G. (Eds.): Evapotranspiration 
    % and Irrigation Water Requirements: ASCE Manuals and Reports on 
    % Engineering Practices No. 70, American Society of Civil Engineers, 
    % New York, 360 pp., 1990.
    %
    % Parameters:
    % e_v: Vapour pressure [hPa]
    % P: Station level pressure [hPa]
    % Td: Dewpoint temperature [deg C]
    % t: Dry-bulb temperature [deg C]
    %
    % Returns:
    % Tw: Wet-bulb temperature [deg C]

    % Calculate coefficients
    a = 0.000066 * P;
    b = (409.8 * e_v) ./ ((Td + 237.3).^2);

    % Calculate wet-bulb temperature
    Tw = ((a .* t) + (b .* Td)) ./ (a + b);
end
