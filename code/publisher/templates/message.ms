<div class="message" data-id="{{_id}}">
	<div class="msgright">
		<div class="metadata">
			by {{creator}} @ {{time}}
		</div>
		<div class="msgaction">
			{{#can_publish}}
			{{^published}}
			<button class="btn-pub">Pub</button>
			{{/published}}
			{{#published}}
			<button class="btn-pub">Unpub</button>
			{{/published}}
			{{/can_publish}}
			{{#can_delete}}
			<button class="btn-del">Del</button>
			{{/can_delete}}
		</div>
	</div>
	<div class="messagebody">
		{{text}}
		{{#file}}
		<div class="msgimg"><img src="{{static}}images/{{file}}"></div>
		{{/file}}
	</div>
	<div style="clear: both;"></div>
</div>