class_name MultiPageUIManager
extends Control


### Private variables ###
var _pages: Dictionary
var _current_page: MultiPageUIPage

### Onready variables ###
@onready var _page_container: Control = $Pages


############################
# Engine Callback Methods  #
############################
func _ready() -> void:
	var viewport_size: Vector2 = get_viewport().size
	
	for child in $Pages.get_children():
		assert(child is MultiPageUIPage)
		_pages[child.name] = child
		print ("manager: " + child.name + "=" + str(child))
		var page_pos: Vector2 = (child as MultiPageUIPage).cords
		page_pos.x *= viewport_size.x
		page_pos.y *= viewport_size.y
		(child as MultiPageUIPage).position = page_pos
		
		if _current_page == null: # child[0] becomes the initial page
			_current_page = child
			_current_page.visible = true
			_current_page.active = true
			_current_page.change_page_request.connect(_on_change_page_request)
		else:
			child.visible = false
	
	get_viewport().size_changed.connect(_on_viewport_size_changed)


############################
# Signal Connected Methods #
############################
func _on_viewport_size_changed() -> void:
	var viewport_size: Vector2 = get_viewport().size
	# Move page container
	_page_container.position = Vector2(
			_current_page.cords.x * -viewport_size.x,
			_current_page.cords.y * -viewport_size.y
	)
	
	# Move pages in container
	for key in _pages.keys():
		var page: MultiPageUIPage = _pages[key]
		var page_pos: Vector2 = Vector2(
				page.cords.x * viewport_size.x,
				page.cords.y * viewport_size.y
		)
		page.position = page_pos


func _on_change_page_request(page_name: String) -> void:
	assert(_pages.has(page_name))
	_change_current_page(page_name)


############################
#      Private Methods     #
############################
func _change_current_page(new_page_name: String) -> void:
	var viewport_size: Vector2 = get_viewport().size
	var target_page: MultiPageUIPage = _pages[new_page_name]
	var old_page: MultiPageUIPage = _current_page
	print ("change_current_page: " + new_page_name + " " + str(_current_page))
	var cord_change: Vector2 = old_page.cords - target_page.cords 
	var position_change = Vector2(
			cord_change.x * viewport_size.x,
			cord_change.y * viewport_size.y
	)

	old_page.active = false
	old_page.change_page_request.disconnect(_on_change_page_request)
	target_page.visible = true

	var tween: Tween = create_tween()
	var _page_rect_pos_tweener: PropertyTweener = tween.tween_property(
			_page_container, "position", 
			position_change, 1
	).as_relative().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.play()
	await tween.finished

	_current_page.visible = false
	_current_page = target_page
	_current_page.active = true
	_current_page.change_page_request.connect(_on_change_page_request)

