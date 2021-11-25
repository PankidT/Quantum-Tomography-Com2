clear;clc
%Determine ideal state
phi_ideal = 0;
theta_ideal = pi/2;

x_ideal = sin(theta_ideal)*cos(phi_ideal);
y_ideal = sin(theta_ideal)*sin(phi_ideal);
z_ideal = cos(theta_ideal);

%dit = direct inversion tomography
num_measure = 10000; %determine number of measurement per basis(XYZ)
prepare_err = true; %error of prepared state
if prepare_err == true
    [x_dit, y_dit, z_dit] = dit_err(phi_ideal,theta_ideal, num_measure);
else
    [x_dit, y_dit, z_dit] = dit(phi_ideal,theta_ideal, num_measure);
end
%md = minimum distance
[x_md, y_md, z_md] = md_analytic(x_dit,y_dit,z_dit); %analytic solution
[xmd_numer, ymd_numer, zmd_numer] = md_numer(x_dit,y_dit,z_dit); %optimization

%mfd = maxfidelity
[x_mfd,y_mfd,z_mfd] = mfd(x_dit, y_dit, z_dit);

%Plot Bloch sphere
hold on
ax1 = plot3(x_ideal,y_ideal,z_ideal,'.','MarkerSize',20,'MarkerEdgeColor','green','MarkerFaceColor',[1 .6 .6]);
ax2 = plot3(x_dit,y_dit,z_dit,'.','MarkerSize',20,'MarkerEdgeColor','red','MarkerFaceColor',[1 .6 .6]);
ax3 = plot3(x_md,y_md,z_md,'.','MarkerSize',20,'MarkerEdgeColor','blue','MarkerFaceColor',[1 .6 .6]);
ax4 = plot3(xmd_numer,ymd_numer,zmd_numer,'.','MarkerSize',20,'MarkerEdgeColor','magenta','MarkerFaceColor',[1 .6 .6]);
ax5 = plot3(x_mfd,y_mfd,z_mfd,'.','MarkerSize',20,'MarkerEdgeColor','#EDB120','MarkerFaceColor',[1 .6 .6]);

[Xs, Ys, Zs] = sphere ;
mysphere = surf( Xs, Ys, Zs) ;
line([-1 1],[0 0],[0 0],'LineWidth',1,'Color',[0 0 0])
line([0 0],[-1 1],[0 0],'LineWidth',1,'Color',[0 0 0])
line([0 0],[0 0],[-1 1],'LineWidth',1,'Color',[0 0 0])
text(0,0.1,1.1,' z ','Interpreter','latex','FontSize',20,'HorizontalAlignment','Center')
text(1.1,0,0,' x ','Interpreter','latex','FontSize',20,'HorizontalAlignment','Center')
text(0,1.1,0,' y ','Interpreter','latex','FontSize',20,'HorizontalAlignment','Center')
text(0,0,-1.1,'$\left| 1 \right>$','Interpreter','latex','FontSize',20,'HorizontalAlignment','Center')
text(0,0,1.1,'$\left| 0 \right>$','Interpreter','latex','FontSize',20,'HorizontalAlignment','Center')
%v = [x_dit y_dit z_dit];
v = [1 0.4 0.2];
[caz,cel] = view(v);
axis equal
shading interp
mysphere.FaceAlpha = 0.25;
xlabel('x', 'FontSize',16)
ylabel('y', 'FontSize',16)
zlabel('z', 'FontSize',16)
legend('Ideal state', 'Direct inversion tomography','surface point at minimum distance(analytic)','surface point at minimum distance(numerical)','mfd')
hold off



%direct inversion tomography 
function [x_dit, y_dit, z_dit] = dit(phi_ideal,theta_ideal, N)
    x_ideal = sin(theta_ideal)*cos(phi_ideal);
    y_ideal = sin(theta_ideal)*sin(phi_ideal);
    z_ideal = cos(theta_ideal);
    Nx_up = 0;
    Nx_down = 0;
    Ny_up = 0;
    Ny_down = 0;
    Nz_up = 0;
    Nz_down = 0;
    Px_up = (1+x_ideal)/2 ;
    Py_up = (1+y_ideal)/2;
    Pz_up = (1+z_ideal)/2;
    for n = 1:N
        if rand < Px_up
            Nx_up = Nx_up + 1;
        else 
            Nx_down = Nx_down + 1;
        end
        if rand < Py_up
             Ny_up = Ny_up + 1;
        else
             Ny_down = Ny_down + 1;
        end
        if rand < Pz_up
             Nz_up = Nz_up + 1;
        else
             Nz_down = Nz_down + 1;
        end
    end
    x_dit = (Nx_up-Nx_down)/(Nx_up+Nx_down);
    y_dit = (Ny_up-Ny_down)/(Ny_up+Ny_down);
    z_dit = (Nz_up-Nz_down)/(Nz_up+Nz_down);
end
function [x_dit, y_dit, z_dit] = dit_err(phi_ideal,theta_ideal, N)
    Nx_up = 0;
    Nx_down = 0;
    Ny_up = 0;
    Ny_down = 0;
    Nz_up = 0;
    Nz_down = 0;
    err =1;
    for n = 1:N
        x_ideal = sin(theta_ideal + 2*rand*err-err)*cos(phi_ideal + 2*rand*err-err);
        y_ideal = sin(theta_ideal + 2*rand*err-err)*sin(phi_ideal + 2*rand*err-err);
        z_ideal = cos(theta_ideal + 2*rand*err-err);
        Px_up = (1+x_ideal)/2 ;
        Py_up = (1+y_ideal)/2;
        Pz_up = (1+z_ideal)/2;
        if rand < Px_up
            Nx_up = Nx_up + 1;
        else 
            Nx_down = Nx_down + 1;
        end
        
        if rand < Py_up
             Ny_up = Ny_up + 1;
        else
             Ny_down = Ny_down + 1;
        end
        
        if rand < Pz_up
             Nz_up = Nz_up + 1;
        else
             Nz_down = Nz_down + 1;
        end
    end
    x_dit = (Nx_up-Nx_down)/(Nx_up+Nx_down);
    y_dit = (Ny_up-Ny_down)/(Ny_up+Ny_down);
    z_dit = (Nz_up-Nz_down)/(Nz_up+Nz_down);
end


%minimum distance 
function [x_md, y_md, z_md] = md_analytic(x_dit,y_dit,z_dit)
    r=sqrt(x_dit^2+y_dit^2+z_dit^2);
    phi_md=atan2(y_dit,x_dit);
    theta_md=acos(z_dit/r);
    x_md =sin(theta_md)*cos(phi_md);
    y_md =sin(theta_md)*sin(phi_md);
    z_md =cos(theta_md);
end

%numerical method for minimum distance 
function [xmd_numer, ymd_numer, zmd_numer] = md_numer(x_dit,y_dit,z_dit)
    theta_initial = pi*rand ;
    phi_initial = 2*pi*rand ;
    alpha = 0.01; %learning rate
    phi = phi_initial;
    theta = theta_initial;
    obj_new = r_square(x_dit,y_dit,z_dit,theta,phi);
    obj_old = 1000000;
    while obj_new < obj_old
        obj_old = obj_new;
        theta = theta - alpha*devtheta(x_dit,y_dit,z_dit,theta,phi);
        phi = phi - alpha*devphi(x_dit,y_dit,theta,phi);
        obj_new = r_square(x_dit,y_dit,z_dit,theta,phi);
    end
    xmd_numer = sin(theta)*cos(phi);
    ymd_numer = sin(theta)*sin(phi);
    zmd_numer = cos(theta);
    
    %distance square
    function d = r_square(x_dit,y_dit,z_dit,theta,phi)
        d = (x_dit-sin(theta)*cos(phi))^(2) + (y_dit-sin(theta)*sin(phi))^(2) + (z_dit-cos(theta))^(2);
    end
    
    %derivative of distance square
    function d = devphi(x,y,theta,phi)
        d = 2*sin(theta)*(x*sin(phi)-y*cos(phi));
    end
    function d = devtheta(x,y,z,theta,phi)
        d = 2*(((sin(phi).^(2)+cos(phi).^(2)-1)*cos(theta)+z)*sin(theta) + (-y*sin(phi)-x*cos(phi))*cos(theta));
    end
end

%max fidelity
function [x_mfd,y_mfd,z_mfd] = mfd(x, y, z)
    
    i_mat = [1 0; 0 1];
    x_mat = [0 1; 1 0];
    y_mat = [0 -1i; 1i 0];
    z_mat = [1 0; 0 -1];
    rho_cart = 0.5*(i_mat + x_mat*x + y_mat*y + z_mat*z);
    
    theta = atan(y/x);
    phi = atan(sqrt(x^2 + y^2)/z);
    theta_dum = linspace(0, 180, 181);
    phi_dum = linspace(0, 360, 361);
    
    index_theta=0;
    index_phi=0;
    for iter_theta = 0:180 
        index_theta = index_theta + 1;
        temp_theta = iter_theta*(pi/180);
        for iter_phi = 0:360 
            index_phi = index_phi + 1;
            temp_phi = iter_phi*(pi/180);
            
            dum1 = cos(temp_theta/2)^2;
            dum2 = exp(-1i*temp_phi)*cos(temp_theta/2)*sin(temp_theta/2);
            dum3 = exp(1i*temp_phi)*cos(temp_theta/2)*sin(temp_theta/2);
            dum4 = sin(temp_theta/2)^2;
            rho_sp = [dum1 dum2; dum3 dum4];
            
            fidelity = sqrtm(sqrtm(rho_cart)*rho_sp*sqrtm(rho_cart));
            fidelity = fidelity(1,1)+fidelity(2,2);
            
            fidel(index_theta, index_phi) = fidelity;
        end
        index_phi=0;
    end
    
    
    max_fidelity = max(max(real(fidel)));
    for row=1:181
        for col=1:361
            if real(fidel(row,col)) == max_fidelity
                theta = row*pi/180;
                phi = col*pi/180;
            end
        end
    end
    x_mfd = sin(theta)*cos(phi);
    y_mfd = sin(theta)*sin(phi);
    z_mfd = cos(theta);
end