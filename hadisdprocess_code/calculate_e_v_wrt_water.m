

%% Calculate water pressure relative to water
function e_v = calculate_e_v_wrt_water(t, P)
    % Calculate vapour pressure with respect to ice
    %
    % Buck, A. L.: New equations for computing vapor pressure and 
    % enhancement factor, J. Appl. Meteorol., 20, 1527–1532, 1981.
    %
    % Inputs:
    %   t - Temperature (or dewpoint temperature for saturation e_v) [deg C]
    %   P - Station level pressure [hPa]
    %
    % Outputs:
    %   e_v - Vapour pressure (or saturation vapour pressure if 
    %         dewpoint temperature used) [hPa]
    %   q  -  specific humidity (g/kg)
    
    % Compute enhancement factor:计算增强因子（Enhancement Factor）：用于修正由于大气压力对水汽压的微小影响
    f = 1 + (3e-4) + (4.18e-6) * P;
    
    % Compute vapour pressure with respect to ice
    e_v = 6.1115 * f .* exp(((23.036 - (t ./ 333.7)) .* t) ./ (279.82 + t));

    % specific humidity
    % q = 1000. * ((0.622 .* e_v) ./ (P - ((1 - 0.622) .* e_v)));

end
