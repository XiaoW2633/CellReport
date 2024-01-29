elementGroupLabels = {'field u', 'kernel u -> u', 'stimulus 1'};
elementGroups = {'field u', 'u -> u', 'stimulus 1'};

gui = StandardGUI(sim, [50, 50, 1000, 600], 0.01, [0.0, 0.3, 1.0, 0.7], [1, 2], 0.075, ...
  [0.0, 0.0, 1.0, 0.3], [6, 4], elementGroupLabels, elementGroups);

gui.addVisualization(ScaledImage('field u', 'activation', [-10, 10], {}, {}, 'field u activation'), [1, 1]);
gui.addVisualization(ScaledImage('field u', 'output', [0, 1], {}, {}, 'field u output'), [1, 2]);

% add sliders
% resting level and noise
gui.addControl(ParameterSlider('h', 'field u', 'h', [-10, 0], '%0.1f', 1, 'resting level of field u'), [1, 1]);


% lateral interactions
gui.addControl(ParameterSlider('c_exc', 'u -> u', 'amplitudeExc', [0, 50], '%0.1f', 1, ...
  'strength of lateral excitation'), [2, 1]);
gui.addControl(ParameterSlider('c_inh', 'u -> u', 'amplitudeInh', [0, 50], '%0.1f', 1, ...
  'strength of lateral inhibition'), [2, 2]);
gui.addControl(ParameterSlider('c_glob', 'u -> u', 'amplitudeGlobal', [0, 0.25], '%0.3f', -1, ...
  'strength of global inhibition'), [2, 3]);

gui.addControl(ParameterSlider('sigmaE', 'u -> u', 'sigmaExc', [0, 50], '%0.1f', 1, ...
  'strength of lateral excitation'), [3, 1]);
gui.addControl(ParameterSlider('sigmaI', 'u -> u', 'sigmaInh', [0, 50], '%0.1f', 1, ...
  'strength of lateral inhibition'), [3, 2]);
gui.addControl(ParameterSlider('v', 'u -> u', 'velocity', [0, 2000], '%0.1f', 1, ...
  'strength of CD signal'), [3, 3]);
% stimuli
gui.addControl(ParameterSlider('px_s1', 'stimulus 1', 'positionX', [0, fieldSize], '%0.1f', 1, ...
  'horizontal position of stimulus 1'), [4, 1]);
gui.addControl(ParameterSlider('py_s1', 'stimulus 1', 'positionY', [0, fieldSize], '%0.1f', 1, ...
  'vertical position of stimulus 1'), [4, 2]);
gui.addControl(ParameterSlider('a_s1', 'stimulus 1', 'amplitude', [0, 20], '%0.1f', 1, ...
  'amplitude of stimulus 1'), [4, 3]);



% add buttons
gui.addControl(GlobalControlButton('Pause', gui, 'pauseSimulation', true, false, false, 'pause simulation'), [1, 4]);
gui.addControl(GlobalControlButton('Reset', gui, 'resetSimulation', true, false, true, 'reset simulation'), [2, 4]);
gui.addControl(GlobalControlButton('Parameters', gui, 'paramPanelRequest', true, false, false, 'open parameter panel'), [3, 4]);
gui.addControl(GlobalControlButton('Save', gui, 'saveParameters', true, false, true, 'save parameter settings'), [4, 4]);
gui.addControl(GlobalControlButton('Load', gui, 'loadParameters', true, false, true, 'load parameter settings'), [5, 4]);
gui.addControl(GlobalControlButton('Quit', gui, 'quitSimulation', true, false, false, 'quit simulation'), [6, 4]);