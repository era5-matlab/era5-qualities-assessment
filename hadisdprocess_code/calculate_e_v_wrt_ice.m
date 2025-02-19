
%% Calculate the air pressure of water relative to ice
function e_v = calculate_e_v_wrt_ice(t, P)
    % Calculate vapour pressure with respect to ice
    %
    % Reference:
    % Buck, A. L.: New equations for computing vapor pressure and enhancement factor, 
    % J. Appl. Meteorol., 20, 1527–1532, 1981.
    %
    % Parameters:
    % t: Temperature (or dewpoint temperature for saturation e_v) [deg C]
    % P: Station level pressure [hPa]
    %
    % Returns:
    % e_v: Vapour pressure (or saturation vapour pressure if dewpoint temperature is used) [hPa]

    % Calculate enhancement factor
    f = 1 + (3e-4) + (4.18e-6) .* P;

    % Calculate vapour pressure
    e_v = 6.1115 .* f .* exp(((23.036 - (t ./ 333.7)) .* t) ./ (279.82 + t));

end
