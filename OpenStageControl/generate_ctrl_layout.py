import json

row_count = 8
col_count = 8
grid_height = 400
grid_width = 600
button_spacing = 5
button_height = (grid_height / row_count) 
button_width = (grid_width / col_count) 	 


def generate_layout_data( tabs ):
	
	layout_data = {}
	layout_data['type'] = "root"
	layout_data['tabs'] = tabs
	
	layout_data['color'] = "@{color_picker}"
	#layout_data['css'] = ":root{--color-text: rgba(255,255,255,0.6);--color-text-fade: rgba(255,255,255,0.4);--color-accent: #1585f6;--color-grid:  rgba(21,133,246,0.05);--color-bg: #0e1215;--color-track: #13191c;--color-fg: #161a1d;--color-raised: #171c20;--color-light: rgba(136,136,136,0.05);--color-white: white;--color-custom: var(--color-accent);--color-glass: var(--color-accent);--glass-opacity: 0.03;--nav-height:40rem;--sidepanel-size:300rem;--scrollbar-size:20rem;--grid-width:10}.keyboard-container{--color-black: #555}"
	layout_data['css'] = ""
	layout_data['value'] = ""
	layout_data['precision'] = 0
	layout_data['address'] = "/root"
	layout_data['preArgs'] = []
	layout_data['target'] = []
	layout_data['variables'] = {}
	layout_data['id'] = "root"
	layout_data['linkId'] = ""
	layout_data['default'] = ""
	layout_data['bypass'] = False
	layout_data['traversing'] = False
	layout_data['scroll'] = True
	layout_data['label'] = False

	return layout_data

def generate_tab_data(widgets):
	
	tab_data = {}
	tab_data['type'] = "tab"
	tab_data['id'] = "tab_2"
	tab_data['label'] = "Open Stage Control"
	tab_data['color'] = "auto"
	tab_data['css'] = ""
	tab_data['value'] = ""
	tab_data['precision'] = 0
	tab_data['address'] = "/tab_2"
	tab_data['preArgs'] = []
	tab_data['target'] = []                           
	tab_data['variables'] = "@{parent.variables}"     
	tab_data['widgets'] = widgets
	return tab_data

def generate_widget_data(button_type,w_id,top,left,width,height,on,channel,note,css,led):
	
	widget_data = {}
	widget_data['type'] = button_type
	widget_data['top'] = top
	widget_data['left'] = left
	widget_data['id'] = w_id
	widget_data['linkId'] = ""
	widget_data['width'] = width
	widget_data['height'] = height
	widget_data['label'] = False
	widget_data['color'] = "red"
	widget_data['css'] = css
	widget_data['doubleTap'] = False
	widget_data['on'] = on
	widget_data['off'] = 0
	widget_data['value'] = ""
	widget_data['precision'] = 2
	widget_data['address'] = "/note"
	widget_data['target'] = "midi:toVIControl"
	widget_data['bypass'] = False
	widget_data['led'] = led
	widget_data['default'] = ""
	
	pre_args = get_pre_args(channel, note)
	widget_data['preArgs'] = pre_args
	
	return widget_data
	
def get_pre_args(channel,note):
	pre_args = {}
	pre_args = [channel,note]
	
	return pre_args
	
def generate_all_widgets():
	
	widgets = []	
	mgw = generate_main_grid_widgets()
	widgets.extend(mgw)
	
	sgw = generate_secondary_grid_widgets()
	widgets.extend(sgw)
	
	irw = generate_indicator_row_widgets()
	widgets.extend(irw)
	
	bcw = generate_block_column_widgets()
	widgets.extend(bcw)
	
	return widgets
	
def generate_main_grid_widgets():
	mgw = [];
	
	grid_button_count = row_count * col_count
	curr_row = 0
	
	for x in range(row_count):
		curr_col = 0
		for y in range(col_count):
			button_type = "push"
			w_id = "r" + str(curr_row+1) + "c" + str(curr_col+1) 
			top = (2*button_spacing) + (curr_row * button_height)
			left = (2*button_spacing) + (curr_col * button_width)
			width = button_width - (2 * button_spacing)
			height = button_height - (2 * button_spacing)
			channel = 1
			on = 1
			# Buttons start at 0 at bottom left of grid, so first button will be 
			# nn ((col_count * row_count) - col_count) -1 
			note = (grid_button_count - (col_count -1) + curr_col - (curr_row * row_count))-1
			curr_col += 1
			css = ""
			led = False
			widget_data = generate_widget_data(button_type,w_id,top,left,width,height,on,channel,note,css,led)
			
			mgw.append(widget_data)
		curr_row += 1
		
	return mgw
	
	
def generate_secondary_grid_widgets():
	sgw = [];
	
	grid_button_count = row_count * col_count
	curr_row = 0
	
	for x in range(row_count):
		curr_col = 0
		for y in range(col_count):
			button_type = "toggle"
			w_id = "i_r" + str(curr_row+1) + "c" + str(curr_col+1) 
			top = (2*button_spacing) + (curr_row * button_height)
			left = (2*button_spacing) + (curr_col * button_width)
			width = (button_width - (2 * button_spacing))
			height = (button_height - (2 * button_spacing))
			channel = 2
			on = 1
			# Buttons start at 0 at bottom left of grid, so first button will be 
			# nn ((col_count * row_count) - col_count) -1 
			note = (grid_button_count - (col_count -1) + curr_col - (curr_row * row_count))-1
			curr_col += 1
			css = "pointer-events:none;z-index:100"
			#css = ""
			led = True;
			
			widget_data = generate_widget_data(button_type,w_id,top,left,width,height,on,channel,note,css,led)
			
			sgw.append(widget_data)
		curr_row += 1
		
	return sgw


def generate_indicator_row_widgets():
	irw = [];
	
	curr_col = 0

	for y in range(col_count):
		button_type = "toggle"
		w_id = "ind" + str(curr_col+1) 
		top = (2*button_spacing) + (grid_height)
		left = (2*button_spacing) + (curr_col * button_width)
		width = button_width - (2 * button_spacing)
		height = button_height - (2 * button_spacing)
		on = 1
		channel = 1
		note = 64+ curr_col
		
		curr_col += 1
		
		css = ""
		led = False
		widget_data = generate_widget_data(button_type,w_id,top,left,width,height,on,channel,note,css,led)
		
		irw.append(widget_data)

	return irw
	
def generate_block_column_widgets():
	bcw = [];
	
	curr_row = 0

	for x in range(row_count):
		
		w_id = "block" + str(curr_row+1) 
		top = (2*button_spacing) + (curr_row * button_height)
		left = (2*button_spacing) + (grid_width)
		width = button_width - (2 * button_spacing)
		height = button_height - (2 * button_spacing)
		
		
		button_type = "toggle"
		channel = 1
		on = 1
	
		#if curr_row > 3 :
		#	button_type = "toggle"
		#	channel = 1
		#	on = 1
		#else :
		#	button_type = "push"
		#	channel = 10
		#	on = curr_row + 1
			
		note = 82 + curr_row
		
		curr_row += 1
		css = ""	
		led = False
		widget_data = generate_widget_data(button_type,w_id,top,left,width,height,on,channel,note,css,led)
		
		bcw.append(widget_data)

	return bcw
	
widgets = generate_all_widgets()

tab_data = generate_tab_data(widgets)

tabs = []
tabs.append(tab_data)

layout_data = generate_layout_data(tabs)
json_data = json.dumps(layout_data, indent=4)
print (json_data)

