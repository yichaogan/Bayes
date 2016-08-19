clear all

% Simulate the data

model_experiment.type = 'first_order_homogenous'; % first_order_homogenous, first_order, second order, Navier-Stokes
model_experiment.coefficients = [1, 2]; % 1, 2, 3, ... coefficients
coefficients=[1, 0.1, 0, 1, 2]; %  [y_initial, delta_t, t(0), t(end)]
noise.isnoise = true;
noise.sigma_noise = 0.05;


q_experiment=makedist('Normal','mu',0,'sigma',noise.sigma_noise); % distribution normale centr�e en 0

measurements = simulate_data(model_experiment, coefficients, noise, q_experiment); % measurements.y, measurements.t, measurements.number

plot(measurements.t,measurements.y)
%% Computation of the model

model = 'first_order_homogenous';
prior.lower_a = 0; % borne inf�rieure pour la prior uniforme sur a
prior.upper_a = 2; % borne sup�rieure
prior.lower_b = 0; % idem pour b
prior.upper_b = 4;


number_samples = 50; % nombres de d'�chantillons
M = 100; % nombre d'it�rations pour la cha�ne de Markov
sigma_algorithm=0.1;
q_algorithm=makedist('Normal','mu',0,'sigma',sigma_algorithm); % distribution normale centr�e en 0

scheme = 1; % upwind 1, downwind -1, center 0
several_scheme = false;

[ parameters ] = initialization_MCMC( measurements, model, scheme, prior, number_samples, sigma_algorithm, several_scheme);

total_acceptance = 0;

for i=1:M % � chaque it�ration, on fait :
    N=length(parameters.coefficients(1,:));

    compteur = 0;
    
    for k=1:N % pour chaque �chantillon, on fait :
    [ parameters, compteur ] = markov_iteration( measurements, model, parameters, M, sigma_algorithm, q_algorithm, k, compteur );
    end
    
    acceptance=compteur/N;
    total_acceptance = total_acceptance + acceptance;
    calcul_effectue = i/M;
    avancement = strcat({'Avancement: '}, {num2str(100*calcul_effectue)}, {'%'});
    display(avancement);
end

acceptance_ratio = strcat({'Acceptance ratio: '},{num2str(100*total_acceptance/M)},{'%'});
display(acceptance_ratio);




if strcmp(model,'first_order_homogenous')
    figure()
    histogram(parameters.coefficients(1,:),'BinWidth', noise.sigma_noise)
    title(parameters.scheme);
    xlabel('a');
elseif strcmp(model,'first_order')
    figure()
    histogram(parameters.coefficients(1,:),'BinWidth', noise.sigma_noise)
    title(parameters.scheme);
    xlabel('a');    
    figure()
    histogram(parameters.coefficients(2,:),'BinWidth', noise.sigma_noise)
    title(parameters.scheme);
    xlabel('b');
end

