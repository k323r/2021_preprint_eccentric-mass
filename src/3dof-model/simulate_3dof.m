MAX_TIME = 30;
DO_ANIMATE = 1;

DO_WRITE_GIF = 0;
filename = 'trajectory.gif';

m1 = 0.05;
m2 = 0.1;
d = 0.05;
k1 = 25;
k2 = 1;
I = 0.002;
damp_theta = 0;


% Initial conditions.
start_x = 0.2;
start_y = 0.2;

f0_bending = 1 / (2 * pi) * sqrt(k1 / (m1 + m2))
f0_torsion = 1 / (2 * pi) * sqrt(k2 / (I + m2 * d^2))

t = [0:0.0001:MAX_TIME];
x = nan(size(t));
u = nan(size(t));
udot = nan(size(t));
y = nan(size(t));
v = nan(size(t));
vdot = nan(size(t));
theta = nan(size(t));
omega = nan(size(t));
omegadot = nan(size(t));


x(1) = start_x;
u(1) = 0;
udot(1) = 0;
y(1) = start_y;
v(1) = 0;
vdot(1) = 0;
theta(1) = 0;
omega(1) = 0;
omegadot(1) = 0;


for i = 2 : length(t)
    dt = t(i) - t(i - 1);
    
    theta_now = theta(i - 1);
    omega_now = omega(i - 1);
    omegadot_now = omegadot(i - 1);
    x_now = x(i - 1);
    y_now = y(i - 1);
    
    % Differential equation for x
    udot(i) = 1 / (m1 + m2) * (cos(theta_now) * m2 * d * omegadot_now ...
        - sin(theta_now) * m2 * d * omega_now^2 ...
        - k1 * x_now);
    
    u(i) = u(i - 1) + udot(i) * dt;
    x(i) = x(i - 1) + u(i) * dt;
    
    % Differential equation for y
    vdot(i) = 1 / (m1 + m2) * (sin(theta_now) *  m2 * d * omegadot_now ...
        + cos(theta_now) * m2 * d * omega_now^2 ...
        - k1 * y_now);
    
    v(i) = v(i - 1) + vdot(i) * dt;
    y(i) = y(i - 1) + v(i) * dt;
    
    % Differential equation for theta
    omegadot(i) = 1 / (I + m2 * d^2) * (cos(theta_now) * m2 * d * udot(i) ...
        + sin(theta_now) * m2 * d * vdot(i) ...
        - damp_theta * omega_now ...
        - k2 * theta_now);
    
    omega(i) = omega(i - 1) + omegadot(i) * dt;
    theta(i) = theta(i - 1) + omega(i) * dt;
end

fig1 = figure();
yyaxis left
plot(t,x,t,y)
ylabel('Position (m)')
yyaxis right
h = plot(t, theta / pi * 180)
ylim(max(abs(h.Parent.YLim)).*[-1 1])
ylabel('\theta (deg)');

xlabel('Time (s)');
legend('x', 'y', '\theta')

fig2 = figure();
plot(x, y, '-');
hold on
plot(x(1), y(1), 'xr')
text(x(1), y(1), 'start', 'color', 'r')
xlabel('x (m)');
ylabel('y (m)');
axis equal

if DO_ANIMATE
    fig3 = figure();
    %set(gca, 'visible', 'off');
    set(gcf,'color','w');
    
    xlabel('x (m)');
    ylabel('y (m)');
    axis equal
    lim_val = sqrt(start_x^2 + start_y^2);
    axis([-lim_val, lim_val, -lim_val, lim_val] * factor)
    step_size = 50;
    gif_step_size = 1000;
    h_line = animatedline;
    for i = 1 : step_size : length(t)
        addpoints(h_line, x(i), y(i));
        title([num2str(t(i)) ' s']);
        drawnow
        
        if DO_WRITE_GIF && mod(i, gif_step_size) == 1
            % Capture the plot as an image 
            frame = getframe(fig3); 
            im = frame2im(frame); 
            [imind,cm] = rgb2ind(im,16); 
            % Write to the GIF File 
            if i == 1 
              imwrite(imind,cm,filename,'gif', 'Loopcount',inf); 
            else 
              imwrite(imind,cm,filename,'gif','WriteMode','append'); 
            end 
        end
    end

end
