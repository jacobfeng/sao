
%% Basic use. Panel is just like subplot.

% (a) Create a grid of panels.
% (b) Plot into each sub-panel.



%% (a)

% create a 2x2 grid in gcf (this will create a figure, if
% none is open).
%
% you can pass the figure handle to the constructor if you
% need to attach the panel to a particular figure, as p =
% panel(h_figure).

p = panel();
p.pack(2, 2);



%% (b)

% plot into each panel in turn

for m = 1:2
	for n = 1:2
		
		% select one of the 2x2 grid of sub-panels
		p(m, n).select();
		
		% plot some data
		plot(randn(100,1));
		
		% you can use all the usual calls
		xlabel('sample number');
		ylabel('data');
		
		% and so on - generally, you can treat the axis panel
		% like any other axis
		axis([0 100 -3 3]);
		
	end
end


