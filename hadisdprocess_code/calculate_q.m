
%% specific humidity
function q = calculate_q(e_v, P)
    % specific humidity
    q = 1000. * ((0.622 .* e_v) ./ (P - ((1 - 0.622) .* e_v)));
end
