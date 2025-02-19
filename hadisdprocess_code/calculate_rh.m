
%% Calculate relative humidity
function rh = calculate_rh(e_v, es)
   
    % Calculate relative humidity
    % Inputs:
    %   e_v - Vapour pressure (hPa)
    %   es  - Saturation vapour pressure (hPa)
    %
    % Output:
    %   rh - Relative humidity (%rh)

    % Calculate relative humidity
    rh = (e_v ./ es) * 100;  % 相对湿度公式
end

